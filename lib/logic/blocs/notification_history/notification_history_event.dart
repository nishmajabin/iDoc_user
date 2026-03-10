import 'package:equatable/equatable.dart';

abstract class NotificationHistoryEvent extends Equatable {
  const NotificationHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load / start watching notifications for a user.
class LoadNotificationHistory extends NotificationHistoryEvent {
  final String userId;
  const LoadNotificationHistory({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Mark a single notification as read.
class MarkNotificationRead extends NotificationHistoryEvent {
  final String userId;
  final String notificationId;

  const MarkNotificationRead({
    required this.userId,
    required this.notificationId,
  });

  @override
  List<Object?> get props => [userId, notificationId];
}

/// Mark all notifications as read.
class MarkAllNotificationsRead extends NotificationHistoryEvent {
  final String userId;
  const MarkAllNotificationsRead({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Delete a single notification.
class DeleteNotification extends NotificationHistoryEvent {
  final String userId;
  final String notificationId;

  const DeleteNotification({
    required this.userId,
    required this.notificationId,
  });

  @override
  List<Object?> get props => [userId, notificationId];
}

/// Clear all notifications.
class ClearAllNotifications extends NotificationHistoryEvent {
  final String userId;
  const ClearAllNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}
