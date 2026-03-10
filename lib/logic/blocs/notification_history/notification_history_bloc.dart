import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/notification_item_model.dart';
import 'package:idoc_user/data/services/notification_storage_service.dart';

import 'notification_history_event.dart';
import 'notification_history_state.dart';

class NotificationHistoryBloc
    extends Bloc<NotificationHistoryEvent, NotificationHistoryState> {
  final NotificationStorageService _storage;

  StreamSubscription<List<NotificationItemModel>>? _notifSub;

  NotificationHistoryBloc({NotificationStorageService? storageService})
      : _storage = storageService ?? NotificationStorageService(),
        super(const NotificationHistoryInitial()) {
    on<LoadNotificationHistory>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<DeleteNotification>(_onDelete);
    on<ClearAllNotifications>(_onClearAll);
  }

  // ── Load / Watch ──────────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadNotificationHistory event,
    Emitter<NotificationHistoryState> emit,
  ) async {
    emit(const NotificationHistoryLoading());

    try {
      // Cancel any old subscription.
      await _notifSub?.cancel();

      // Subscribe to real-time changes.
      await emit.forEach<List<NotificationItemModel>>(
        _storage.watchNotifications(event.userId),
        onData: (notifications) {
          final unreadCount =
              notifications.where((n) => !n.isRead).length;
          return NotificationHistoryLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          );
        },
        onError: (error, _) {
          debugPrint('[NotifHistoryBloc] Stream error: $error');
          return NotificationHistoryError(error.toString());
        },
      );
    } catch (e) {
      debugPrint('[NotifHistoryBloc] Load error: $e');
      emit(NotificationHistoryError(e.toString()));
    }
  }

  // ── Mark Read ─────────────────────────────────────────────────────────────

  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationHistoryState> emit,
  ) async {
    await _storage.markAsRead(event.userId, event.notificationId);
    // Real-time stream will auto-emit the updated list.
  }

  // ── Mark All Read ─────────────────────────────────────────────────────────

  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationHistoryState> emit,
  ) async {
    await _storage.markAllAsRead(event.userId);
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> _onDelete(
    DeleteNotification event,
    Emitter<NotificationHistoryState> emit,
  ) async {
    await _storage.deleteNotification(event.userId, event.notificationId);
  }

  // ── Clear All ─────────────────────────────────────────────────────────────

  Future<void> _onClearAll(
    ClearAllNotifications event,
    Emitter<NotificationHistoryState> emit,
  ) async {
    await _storage.clearAll(event.userId);
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    await _notifSub?.cancel();
    return super.close();
  }
}
