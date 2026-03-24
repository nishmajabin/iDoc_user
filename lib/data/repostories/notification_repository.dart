import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/data/models/notification_item_model.dart';
import 'package:idoc_user/data/services/notification_service.dart';
import 'package:idoc_user/data/services/notification_storage_service.dart';
import 'package:uuid/uuid.dart';

class NotificationRepository {
  NotificationRepository({
    NotificationService? notificationService,
    NotificationStorageService? storageService,
    FirebaseFirestore? firestore,
  })  : _notificationService = notificationService ?? NotificationService.instance,
        _storageService = storageService ?? NotificationStorageService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final NotificationService _notificationService;
  final NotificationStorageService _storageService;
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  final _knownAppointmentIds = <String>{};
  final _lastSeenMessageTime = <String, DateTime>{};

  StreamSubscription? _appointmentSub;
  StreamSubscription? _chatRoomSub;
  StreamSubscription? _videoCallSub;
  final _chatMessageSubs = <StreamSubscription>[];

  String? _userId;

  NotificationStorageService get storageService => _storageService;

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> initialize(String userId) async {
    _userId = userId;
    await _notificationService.initialize();
    await _notificationService.storeFcmToken(userId);
    _notificationService.listenForTokenRefresh(userId);
  }

  void listenForAppointments(String userId) {
    _appointmentSub?.cancel();
    _appointmentSub = _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .listen(_handleAppointmentSnapshot,
            onError: (e) => debugPrint('[NotifRepo] Appointment error: $e'));
  }

  void listenForChatMessages(String userId) {
    _chatRoomSub?.cancel();
    for (final s in _chatMessageSubs) s.cancel();
    _chatMessageSubs.clear();

    _chatRoomSub = _firestore
        .collection('chatRooms')
        .where('patientId', isEqualTo: userId)
        .snapshots()
        .listen(
          (snap) {
            for (final doc in snap.docs) _watchChatRoomMessages(doc.id, userId);
          },
          onError: (e) => debugPrint('[NotifRepo] Chat room error: $e'),
        );
  }

  void listenForIncomingCalls(String userId) {
    _videoCallSub?.cancel();
    _videoCallSub = _firestore
        .collection('calls')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snap) {
          for (final c in snap.docChanges.where((c) => c.type == DocumentChangeType.added)) {
            final data = c.doc.data();
            if (data == null) continue;
            final doctorName = data['doctorName'] as String? ?? 'Your doctor';
            _showAndPersist(
              title: '📹 Incoming Video Call',
              body: 'Dr. $doctorName is calling you…',
              payload: '{"type":"video_call","callId":"${c.doc.id}"}',
              type: NotificationType.videoCall,
              data: {'callId': c.doc.id, 'doctorName': doctorName},
            );
          }
        },
        onError: (e) => debugPrint('[NotifRepo] Call listener error: $e'));
  }

  Future<void> removeFcmToken(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('[NotifRepo] Error removing FCM token: $e');
    }
  }

  Future<void> dispose() async {
    _appointmentSub?.cancel();
    _chatRoomSub?.cancel();
    _videoCallSub?.cancel();
    for (final s in _chatMessageSubs) s.cancel();
    _chatMessageSubs.clear();
    _knownAppointmentIds.clear();
    _lastSeenMessageTime.clear();
    await _notificationService.cancelAllNotifications();
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _handleAppointmentSnapshot(QuerySnapshot snapshot) {
    final isFirst = _knownAppointmentIds.isEmpty;
    for (final c in snapshot.docChanges.where((c) => c.type == DocumentChangeType.added)) {
      try {
        final appointment = AppointmentModel.fromFirestore(c.doc);
        final id = c.doc.id;
        _knownAppointmentIds.add(id);
        _scheduleReminderForAppointment(appointment);
        if (isFirst) continue;

        final doctorName = appointment.doctorName ?? 'your doctor';
        _showAndPersist(
          title: '✅ Appointment Confirmed',
          body: 'Your appointment with Dr. $doctorName on '
              '${_formatDate(appointment.appointmentDate)} at '
              '${appointment.startTime} has been confirmed.',
          payload: '{"type":"appointment_confirmed","appointmentId":"$id"}',
          type: NotificationType.appointmentConfirmed,
          data: {'appointmentId': id},
        );
      } catch (e) {
        debugPrint('[NotifRepo] Error parsing appointment: $e');
      }
    }
  }

  void _scheduleReminderForAppointment(AppointmentModel appointment) {
    try {
      final dt = _combineDateTime(appointment.appointmentDate, appointment.startTime);
      final reminderTime = dt.subtract(const Duration(minutes: 10));
      if (reminderTime.isBefore(DateTime.now())) return;

      final doctorName = appointment.doctorName ?? 'your doctor';
      _notificationService.scheduleAppointmentReminder(
        appointmentId: appointment.appointmentId ?? '',
        doctorName: doctorName,
        appointmentDateTime: dt,
        minutesBefore: 10,
      );
      _persist(
        title: '⏰ Upcoming Appointment',
        body: 'Your appointment with Dr. $doctorName is in 10 minutes.',
        type: NotificationType.appointmentReminder,
        data: {'appointmentId': appointment.appointmentId ?? ''},
        overrideTimestamp: reminderTime,
      );
    } catch (e) {
      debugPrint('[NotifRepo] Error scheduling reminder: $e');
    }
  }

  void _watchChatRoomMessages(String chatRoomId, String userId) {
    final sub = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snap) async {
          if (snap.docs.isEmpty) return;
          final data = snap.docs.first.data();
          if ((data['senderId'] as String? ?? '') == userId) return;

          final timestamp = data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now();

          final lastSeen = _lastSeenMessageTime[chatRoomId];
          if (lastSeen != null && !timestamp.isAfter(lastSeen)) return;
          _lastSeenMessageTime[chatRoomId] = timestamp;
          if (lastSeen == null) return; // skip initial load

          final roomDoc = await _firestore.collection('chatRooms').doc(chatRoomId).get();
          final doctorName = roomDoc.data()?['doctorName'] as String? ?? 'Your doctor';
          final messageText = data['messageText'] as String? ?? '';

          _showAndPersist(
            title: '💬 New Message from Dr. $doctorName',
            body: messageText.length > 100 ? '${messageText.substring(0, 100)}…' : messageText,
            payload: '{"type":"new_chat_message","chatRoomId":"$chatRoomId"}',
            type: NotificationType.chatMessage,
            data: {'chatRoomId': chatRoomId},
          );
        },
        onError: (e) => debugPrint('[NotifRepo] Chat message error: $e'));

    _chatMessageSubs.add(sub);
  }

  /// Shows a local notification AND persists it to storage in one call.
  void _showAndPersist({
    required String title,
    required String body,
    required String payload,
    required NotificationType type,
    required Map<String, dynamic> data,
    DateTime? overrideTimestamp,
  }) {
    _notificationService.showNotification(title: title, body: body, payload: payload);
    _persist(title: title, body: body, type: type, data: data, overrideTimestamp: overrideTimestamp);
  }

  void _persist({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    DateTime? overrideTimestamp,
  }) {
    if (_userId == null) return;
    _storageService.saveNotification(NotificationItemModel(
      notificationId: _uuid.v4(),
      userId: _userId!,
      title: title,
      body: body,
      type: type,
      timestamp: overrideTimestamp ?? DateTime.now(),
      isRead: false,
      data: data,
    ));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  DateTime _combineDateTime(DateTime date, String time) {
    try {
      final p = time.split(':');
      return DateTime(date.year, date.month, date.day, int.parse(p[0]), int.parse(p[1]));
    } catch (_) {
      return DateTime(date.year, date.month, date.day);
    }
  }

  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}