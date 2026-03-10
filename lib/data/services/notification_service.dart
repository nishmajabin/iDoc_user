import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Top-level handler for background / terminated FCM messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] Message: ${message.messageId}');
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Shared notification details ───────────────────────────────────────────

  static const _androidDetails = AndroidNotificationDetails(
    'idoc_user_channel',
    'iDoc User Notifications',
    channelDescription:
        'Notifications for appointments, chats, video calls, and reminders',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _notifDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  // ──────────────────────────────────────────────────────────────────────────
  //  INITIALIZATION
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Register the background handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Initialize timezone database.
    tz.initializeTimeZones();
    final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    // 3. Build initialization settings.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    // 4. Initialize the plugin (v20.1.0+ named params).
    await _localNotif.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 5. Create the Android notification channel.
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'idoc_user_channel',
            'iDoc User Notifications',
            description:
                'Notifications for appointments, chats, video calls, and reminders',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );

    // 6. Request permissions (iOS / Android 13+).
    await requestPermission();

    // 7. Listen for foreground FCM messages.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 8. Handle notification tap when app is in background (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 9. Check if the app was launched from a terminated-state notification.
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) _handleMessageOpenedApp(initialMessage);
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  PERMISSION
  // ──────────────────────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    debugPrint('[Notification] Permission granted: $granted');
    return granted;
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  FCM TOKEN
  // ──────────────────────────────────────────────────────────────────────────

  Future<String?> getFcmToken() async {
    try {
      final token = await _fcm.getToken();
      debugPrint('[FCM] Token: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
      return null;
    }
  }

  Future<void> storeFcmToken(String userId) async {
    final token = await getFcmToken();
    if (token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[FCM] Token stored for user: $userId');
  }

  void listenForTokenRefresh(String userId) {
    _fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed: $newToken');
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': newToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  MESSAGE HANDLERS
  // ──────────────────────────────────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM Foreground] ${message.notification?.title}');
    final notification = message.notification;
    if (notification == null) return;
    showNotification(
      title: notification.title ?? 'iDoc',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] App opened from notification: ${message.data}');
    // Navigation logic is handled via the global navigator key in main.dart.
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[Local Notif] Tapped payload: ${response.payload}');
    // Navigation logic is handled via the global navigator key in main.dart.
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  SHOW INSTANT LOCAL NOTIFICATION
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    await _localNotif.show(
      id: id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: _notifDetails,
      payload: payload,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  SCHEDULE LOCAL NOTIFICATION
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required String doctorName,
    required DateTime appointmentDateTime,
    int minutesBefore = 10,
  }) async {
    final scheduledTime =
        appointmentDateTime.subtract(Duration(minutes: minutesBefore));

    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint(
          '[Scheduled Notif] Skipped — reminder time already passed for $appointmentId');
      return;
    }

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final notifId = appointmentId.hashCode.abs() % 2147483647;

    await _localNotif.zonedSchedule(
      id: notifId,
      title: '⏰ Upcoming Appointment',
      body:
          'Your appointment with Dr. $doctorName is in $minutesBefore minutes.',
      scheduledDate: tzScheduledTime,
      notificationDetails: _notifDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: jsonEncode({
        'type': 'appointment_reminder',
        'appointmentId': appointmentId,
      }),
    );

    debugPrint(
        '[Scheduled Notif] Reminder set for $appointmentId at $tzScheduledTime');
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  CANCEL
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> cancelAppointmentReminder(String appointmentId) async {
    final notifId = appointmentId.hashCode.abs() % 2147483647;
    await _localNotif.cancel(id: notifId);
    debugPrint('[Scheduled Notif] Cancelled reminder for $appointmentId');
  }

  Future<void> cancelAllNotifications() async {
    await _localNotif.cancelAll();
    debugPrint('[Scheduled Notif] All notifications cancelled');
  }
}
