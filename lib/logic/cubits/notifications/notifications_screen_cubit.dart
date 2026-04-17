import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/notification_item_model.dart';
import 'package:idoc_user/logic/cubits/notifications/notifications_screen_state.dart';


class NotificationsScreenCubit extends Cubit<NotificationsScreenState> {
  NotificationsScreenCubit() : super(const NotificationsScreenInitial());

  // ── Dialog helpers ────────────────────────────────────────────────────────

  /// Request the UI to show the "Clear All" confirmation dialog.
  void requestClearAll(String userId) {
    emit(NotificationsScreenShowClearDialog(userId: userId));
  }

  /// Reset to idle after the dialog has been handled.
  void dialogHandled() => emit(const NotificationsScreenInitial());

  // ── Card tap routing ──────────────────────────────────────────────────────

  /// Called when the user taps a notification card.
  void handleCardTap(NotificationItemModel notification) {
    final data = notification.data;

    switch (notification.type) {
      case NotificationType.appointmentConfirmed:
      case NotificationType.appointmentReminder:
        emit(NotificationsScreenNavigate(
          target: NotificationNavTarget.appointment,
          payload: data?['appointmentId'] as String?,
        ));
        break;

      case NotificationType.chatMessage:
        emit(NotificationsScreenNavigate(
          target: NotificationNavTarget.chat,
          payload: data?['chatId'] as String?,
        ));
        break;

      case NotificationType.videoCall:
        emit(NotificationsScreenNavigate(
          target: NotificationNavTarget.videoCall,
          payload: data?['callId'] as String?,
        ));
        break;

      case NotificationType.general:
        // No navigation for general notifications.
        break;
    }
  }

  /// Reset to idle after the navigation side-effect has been consumed.
  void navigationHandled() => emit(const NotificationsScreenInitial());
}