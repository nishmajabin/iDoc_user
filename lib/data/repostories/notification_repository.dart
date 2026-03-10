import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/data/models/notification_item_model.dart';
import 'package:idoc_user/data/services/notification_service.dart';
import 'package:idoc_user/data/services/notification_storage_service.dart';
import 'package:uuid/uuid.dart';

/// Repository that bridges the NotificationBloc with the NotificationService
/// and Firestore listeners for appointments, chat messages, and video calls.
class NotificationRepository {
  final NotificationService _notificationService;
  final NotificationStorageService _storageService;
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  /// Tracks which appointment IDs we've already seen, so we only notify
  /// on *new* bookings (not on initial load).
  final Set<String> _knownAppointmentIds = {};

  /// Tracks the last-seen message timestamp per chat room so we only
  /// notify on truly new messages.
  final Map<String, DateTime> _lastSeenMessageTime = {};

  /// Active Firestore subscriptions (cancelled on dispose).
  StreamSubscription<QuerySnapshot>? _appointmentSub;
  StreamSubscription<QuerySnapshot>? _chatRoomSub;
  StreamSubscription<QuerySnapshot>? _videoCallSub;
  final List<StreamSubscription> _chatMessageSubs = [];

  /// The user ID set during initialization — needed for persistence.
  String? _userId;

  NotificationRepository({
    NotificationService? notificationService,
    NotificationStorageService? storageService,
    FirebaseFirestore? firestore,
  })  : _notificationService =
            notificationService ?? NotificationService.instance,
        _storageService = storageService ?? NotificationStorageService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Expose storage service for the history BLoC ───────────────────────────

  NotificationStorageService get storageService => _storageService;

  // ──────────────────────────────────────────────────────────────────────────
  //  INITIALIZATION
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> initialize(String userId) async {
    _userId = userId;
    await _notificationService.initialize();
    await _notificationService.storeFcmToken(userId);
    _notificationService.listenForTokenRefresh(userId);
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  APPOINTMENT LISTENER — confirmed appointments for this user
  // ──────────────────────────────────────────────────────────────────────────

  void listenForAppointments(String userId) {
    _appointmentSub?.cancel();

    _appointmentSub = _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .listen((snapshot) {
      bool isFirstSnapshot = _knownAppointmentIds.isEmpty;

      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final doc = change.doc;
          final appointmentId = doc.id;

          try {
            final appointment = AppointmentModel.fromFirestore(doc);

            if (isFirstSnapshot) {
              _knownAppointmentIds.add(appointmentId);
              _scheduleReminderForAppointment(appointment);
              continue;
            }

            if (!_knownAppointmentIds.contains(appointmentId)) {
              _knownAppointmentIds.add(appointmentId);

              final doctorName = appointment.doctorName ?? 'your doctor';
              final title = '✅ Appointment Confirmed';
              final body =
                  'Your appointment with Dr. $doctorName on ${_formatDate(appointment.appointmentDate)} at ${appointment.startTime} has been confirmed.';

              _notificationService.showNotification(
                title: title,
                body: body,
                payload:
                    '{"type":"appointment_confirmed","appointmentId":"$appointmentId"}',
              );

              // Persist to Firestore.
              _persistNotification(
                title: title,
                body: body,
                type: NotificationType.appointmentConfirmed,
                data: {'appointmentId': appointmentId},
              );

              _scheduleReminderForAppointment(appointment);

              debugPrint(
                  '[NotifRepo] New appointment notification: $appointmentId');
            }
          } catch (e) {
            debugPrint('[NotifRepo] Error parsing appointment doc: $e');
          }
        }
      }
    }, onError: (e) {
      debugPrint('[NotifRepo] Appointment listener error: $e');
    });
  }

  void _scheduleReminderForAppointment(AppointmentModel appointment) {
    try {
      final appointmentDateTime = _combineDateTime(
        appointment.appointmentDate,
        appointment.startTime,
      );

      final reminderTime =
          appointmentDateTime.subtract(const Duration(minutes: 10));

      debugPrint(
          '[NotifRepo] Appointment ${appointment.appointmentId}: '
          'dateTime=$appointmentDateTime, reminderTime=$reminderTime, '
          'now=${DateTime.now()}');

      // Don't schedule or persist if the reminder time has already passed.
      if (reminderTime.isBefore(DateTime.now())) {
        debugPrint(
            '[NotifRepo] Skipped reminder — time already passed for '
            '${appointment.appointmentId}');
        return;
      }

      final doctorName = appointment.doctorName ?? 'your doctor';

      // 1. Schedule the local notification to fire at the correct future time.
      _notificationService.scheduleAppointmentReminder(
        appointmentId: appointment.appointmentId ?? '',
        doctorName: doctorName,
        appointmentDateTime: appointmentDateTime,
        minutesBefore: 10,
      );

      // 2. Persist the reminder record with the future timestamp.
      //    The storage service filters out records with timestamp > now,
      //    so this will only appear in the notification history screen
      //    once the reminder time actually arrives.
      _persistNotification(
        title: '⏰ Upcoming Appointment',
        body:
            'Your appointment with Dr. $doctorName is in 10 minutes.',
        type: NotificationType.appointmentReminder,
        data: {'appointmentId': appointment.appointmentId ?? ''},
        overrideTimestamp: reminderTime,
      );
    } catch (e) {
      debugPrint('[NotifRepo] Error scheduling reminder: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  CHAT MESSAGE LISTENER — messages from doctors to this user
  // ──────────────────────────────────────────────────────────────────────────

  void listenForChatMessages(String userId) {
    _chatRoomSub?.cancel();
    for (final sub in _chatMessageSubs) {
      sub.cancel();
    }
    _chatMessageSubs.clear();

    _chatRoomSub = _firestore
        .collection('chatRooms')
        .where('patientId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (final doc in snapshot.docs) {
        final chatRoomId = doc.id;
        _watchChatRoomMessages(chatRoomId, userId);
      }
    }, onError: (e) {
      debugPrint('[NotifRepo] Chat room listener error: $e');
    });
  }

  void _watchChatRoomMessages(String chatRoomId, String userId) {
    final sub = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) return;

      final latestDoc = snapshot.docs.first;
      final data = latestDoc.data();

      final senderId = data['senderId'] as String? ?? '';
      final messageText = data['messageText'] as String? ?? '';
      final timestamp = data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now();

      // Ignore messages sent by the user themselves.
      if (senderId == userId) return;

      final lastSeen = _lastSeenMessageTime[chatRoomId];
      if (lastSeen != null && !timestamp.isAfter(lastSeen)) return;

      _lastSeenMessageTime[chatRoomId] = timestamp;

      // Skip notification on first snapshot load (initial data).
      if (lastSeen == null) return;

      _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get()
          .then((roomDoc) {
        final roomData = roomDoc.data();
        final doctorName =
            roomData?['doctorName'] as String? ?? 'Your doctor';

        final title = '💬 New Message from Dr. $doctorName';
        final body = messageText.length > 100
            ? '${messageText.substring(0, 100)}…'
            : messageText;

        _notificationService.showNotification(
          title: title,
          body: body,
          payload: '{"type":"new_chat_message","chatRoomId":"$chatRoomId"}',
        );

        // Persist to Firestore.
        _persistNotification(
          title: title,
          body: body,
          type: NotificationType.chatMessage,
          data: {'chatRoomId': chatRoomId},
        );

        debugPrint(
            '[NotifRepo] Chat notification from Dr. $doctorName in $chatRoomId');
      });
    }, onError: (e) {
      debugPrint('[NotifRepo] Chat message listener error: $e');
    });

    _chatMessageSubs.add(sub);
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  VIDEO CALL LISTENER — incoming calls from doctor
  // ──────────────────────────────────────────────────────────────────────────

  void listenForIncomingCalls(String userId) {
    _videoCallSub?.cancel();

    _videoCallSub = _firestore
        .collection('calls')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final doctorName = data['doctorName'] as String? ?? 'Your doctor';
          final callId = change.doc.id;

          final title = '📹 Incoming Video Call';
          final body = 'Dr. $doctorName is calling you…';

          _notificationService.showNotification(
            title: title,
            body: body,
            payload: '{"type":"video_call","callId":"$callId"}',
          );

          // Persist to Firestore.
          _persistNotification(
            title: title,
            body: body,
            type: NotificationType.videoCall,
            data: {
              'callId': callId,
              'doctorName': doctorName,
            },
          );

          debugPrint('[NotifRepo] Incoming call notification from Dr. $doctorName');
        }
      }
    }, onError: (e) {
      debugPrint('[NotifRepo] Video call listener error: $e');
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  PERSIST NOTIFICATION
  // ──────────────────────────────────────────────────────────────────────────

  void _persistNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    DateTime? overrideTimestamp,
  }) {
    if (_userId == null) return;

    final notification = NotificationItemModel(
      notificationId: _uuid.v4(),
      userId: _userId!,
      title: title,
      body: body,
      type: type,
      timestamp: overrideTimestamp ?? DateTime.now(),
      isRead: false,
      data: data,
    );

    _storageService.saveNotification(notification);
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  CLEANUP
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> removeFcmToken(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
      debugPrint('[NotifRepo] FCM token removed for user: $userId');
    } catch (e) {
      debugPrint('[NotifRepo] Error removing FCM token: $e');
    }
  }

  Future<void> dispose() async {
    _appointmentSub?.cancel();
    _chatRoomSub?.cancel();
    _videoCallSub?.cancel();
    for (final sub in _chatMessageSubs) {
      sub.cancel();
    }
    _chatMessageSubs.clear();
    _knownAppointmentIds.clear();
    _lastSeenMessageTime.clear();
    await _notificationService.cancelAllNotifications();
    debugPrint('[NotifRepo] Disposed all notification listeners');
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  DateTime _combineDateTime(DateTime date, String time) {
    try {
      final parts = time.split(':');
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (_) {
      return DateTime(date.year, date.month, date.day);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
