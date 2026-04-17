import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _androidDetails = AndroidNotificationDetails(
    'idoc_user_channel', 'iDoc User Notifications',
    channelDescription: 'Notifications for appointments, chats, video calls, and reminders',
    importance: Importance.high, priority: Priority.high,
    playSound: true, enableVibration: true, icon: '@mipmap/ic_launcher',
  );

  static const _notifDetails = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
  );

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));

    await _localNotif.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'idoc_user_channel', 'iDoc User Notifications',
          description: 'Notifications for appointments, chats, video calls, and reminders',
          importance: Importance.high, playSound: true, enableVibration: true,
        ));

    await requestPermission();
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) _handleMessageOpenedApp(initialMessage);
  }

  Future<bool> requestPermission() async {
    final settings = await _fcm.requestPermission(alert: true, badge: true, sound: true);
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getFcmToken() async {
    try { return await _fcm.getToken(); } catch (_) { return null; }
  }

  Future<void> _updateFcmToken(String userId, String token) =>
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> storeFcmToken(String userId) async {
    final token = await getFcmToken();
    if (token != null) await _updateFcmToken(userId, token);
  }

  void listenForTokenRefresh(String userId) =>
      _fcm.onTokenRefresh.listen((token) => _updateFcmToken(userId, token));

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    showNotification(
      title: notification.title ?? 'iDoc',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {}
  void _onNotificationTap(NotificationResponse response) {}

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) => _localNotif.show(
    id: id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: title, body: body,
    notificationDetails: _notifDetails,
    payload: payload,
  );

  Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required String doctorName,
    required DateTime appointmentDateTime,
    int minutesBefore = 10,
  }) async {
    final scheduledTime = appointmentDateTime.subtract(Duration(minutes: minutesBefore));
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _localNotif.zonedSchedule(
      id: appointmentId.hashCode.abs() % 2147483647,
      title: '⏰ Upcoming Appointment',
      body: 'Your appointment with Dr. $doctorName is in $minutesBefore minutes.',
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: _notifDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: jsonEncode({'type': 'appointment_reminder', 'appointmentId': appointmentId}),
    );
  }

  Future<void> cancelAppointmentReminder(String appointmentId) =>
      _localNotif.cancel(id: appointmentId.hashCode.abs() % 2147483647);

  Future<void> cancelAllNotifications() => _localNotif.cancelAll();
}