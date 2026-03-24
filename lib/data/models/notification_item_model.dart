import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum NotificationType {
  appointmentConfirmed,
  appointmentReminder,
  chatMessage,
  videoCall,
  general,
}

class NotificationItemModel extends Equatable {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  final Map<String, dynamic>? data;

  const NotificationItemModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });


  factory NotificationItemModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationItemModel(
      notificationId: doc.id,
      userId: d['userId'] as String? ?? '',
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      type: _typeFromString(d['type'] as String? ?? 'general'),
      timestamp: d['timestamp'] != null
          ? (d['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: d['isRead'] as bool? ?? false,
      data: d['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      if (data != null) 'data': data,
    };
  }


  NotificationItemModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationItemModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }


  static NotificationType _typeFromString(String value) {
    switch (value) {
      case 'appointmentConfirmed':
        return NotificationType.appointmentConfirmed;
      case 'appointmentReminder':
        return NotificationType.appointmentReminder;
      case 'chatMessage':
        return NotificationType.chatMessage;
      case 'videoCall':
        return NotificationType.videoCall;
      default:
        return NotificationType.general;
    }
  }

  @override
  List<Object?> get props => [
        notificationId,
        userId,
        title,
        body,
        type,
        timestamp,
        isRead,
        data,
      ];
}
