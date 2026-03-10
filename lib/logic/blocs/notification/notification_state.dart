import 'package:equatable/equatable.dart';

/// Base class for all notification states.
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any notification setup.
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Notification system is being initialized (FCM, permissions, etc.).
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Notification system is fully initialized and actively listening.
class NotificationReady extends NotificationState {
  final String userId;

  const NotificationReady({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// An error occurred during notification setup.
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Notification system has been stopped / cleaned up.
class NotificationStopped extends NotificationState {
  const NotificationStopped();
}
