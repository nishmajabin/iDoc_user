import 'package:equatable/equatable.dart';
import 'package:idoc_user/data/models/notification_item_model.dart';

abstract class NotificationHistoryState extends Equatable {
  const NotificationHistoryState();

  @override
  List<Object?> get props => [];
}

class NotificationHistoryInitial extends NotificationHistoryState {
  const NotificationHistoryInitial();
}

class NotificationHistoryLoading extends NotificationHistoryState {
  const NotificationHistoryLoading();
}

class NotificationHistoryLoaded extends NotificationHistoryState {
  final List<NotificationItemModel> notifications;
  final int unreadCount;

  const NotificationHistoryLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationHistoryError extends NotificationHistoryState {
  final String message;
  const NotificationHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
