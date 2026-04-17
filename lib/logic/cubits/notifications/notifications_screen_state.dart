import 'package:equatable/equatable.dart';

/// Base class for all UI-level states of [NotificationsScreen].
abstract class NotificationsScreenState extends Equatable {
  const NotificationsScreenState();

  @override
  List<Object?> get props => [];
}

// ── Concrete states ───────────────────────────────────────────────────────────

/// Idle / default state. No side-effect pending.
class NotificationsScreenInitial extends NotificationsScreenState {
  const NotificationsScreenInitial();
}

/// Signals the UI to show the "Clear All" confirmation dialog.
class NotificationsScreenShowClearDialog extends NotificationsScreenState {
  final String userId;

  const NotificationsScreenShowClearDialog({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Signals the UI to navigate to a specific screen / show a SnackBar.
class NotificationsScreenNavigate extends NotificationsScreenState {
  final NotificationNavTarget target;

  /// Optional deep-link payload (appointmentId, chatId, callId …).
  final String? payload;

  const NotificationsScreenNavigate({
    required this.target,
    this.payload,
  });

  @override
  List<Object?> get props => [target, payload];
}

// ── Navigation target enum ────────────────────────────────────────────────────

enum NotificationNavTarget {
  appointment,
  chat,
  videoCall,
}