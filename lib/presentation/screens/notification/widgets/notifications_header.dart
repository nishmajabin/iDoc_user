import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_bloc.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_event.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_state.dart';
import 'package:idoc_user/logic/cubits/notifications/notifications_screen_cubit.dart';
import 'package:idoc_user/presentation/screens/notification/widgets/notifications_header_action.dart';

class NotificationsHeader extends StatelessWidget {
  final String? userId;

  const NotificationsHeader({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Row(
          children: [
            // ── Bell icon ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.notifications_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // ── Title + unread count ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  BlocBuilder<NotificationHistoryBloc,
                      NotificationHistoryState>(
                    buildWhen: (prev, curr) =>
                        _unreadCount(prev) != _unreadCount(curr),
                    builder: (context, state) {
                      final count = _unreadCount(state);
                      if (count > 0) {
                        return Text(
                          '$count unread',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            // ── Mark all read ────────────────────────────────────────────────
            BlocBuilder<NotificationHistoryBloc, NotificationHistoryState>(
              buildWhen: (prev, curr) =>
                  _unreadCount(prev) != _unreadCount(curr),
              builder: (context, state) {
                if (state is NotificationHistoryLoaded &&
                    state.unreadCount > 0) {
                  return NotificationsHeaderAction(
                    icon: Icons.done_all_rounded,
                    tooltip: 'Mark all as read',
                    onTap: () {
                      if (userId == null) return;
                      context.read<NotificationHistoryBloc>().add(
                            MarkAllNotificationsRead(userId: userId!),
                          );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),

            // ── Clear all ────────────────────────────────────────────────────
            BlocBuilder<NotificationHistoryBloc, NotificationHistoryState>(
              buildWhen: (prev, curr) =>
                  _notificationsEmpty(prev) != _notificationsEmpty(curr),
              builder: (context, state) {
                if (state is NotificationHistoryLoaded &&
                    state.notifications.isNotEmpty) {
                  return NotificationsHeaderAction(
                    icon: Icons.delete_sweep_rounded,
                    tooltip: 'Clear all',
                    onTap: () {
                      if (userId == null) return;
                      context
                          .read<NotificationsScreenCubit>()
                          .requestClearAll(userId!);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  int _unreadCount(NotificationHistoryState state) =>
      state is NotificationHistoryLoaded ? state.unreadCount : 0;

  bool _notificationsEmpty(NotificationHistoryState state) =>
      state is NotificationHistoryLoaded
          ? state.notifications.isEmpty
          : true;
}