import 'package:equatable/equatable.dart';

/// Base class for all notification events.
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes the entire notification system.
/// Should be dispatched once after the user logs in.
class InitializeNotifications extends NotificationEvent {
  final String userId;

  const InitializeNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Starts listening for Firestore changes (appointments + chats + calls).
class StartListeningForNotifications extends NotificationEvent {
  final String userId;

  const StartListeningForNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Stops all listeners and cleans up (e.g. on logout).
class StopNotifications extends NotificationEvent {
  final String userId;

  const StopNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}
