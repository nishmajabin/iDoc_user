import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/notification_item_model.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_bloc.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_event.dart';
import 'package:idoc_user/logic/cubits/notifications/notifications_screen_cubit.dart';
import 'package:idoc_user/presentation/screens/notification/widgets/type_visual.dart'; // adjust to your actual import path

class NotificationCard extends StatelessWidget {
  final NotificationItemModel notification;
  final String userId;

  const NotificationCard({
    required this.notification,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final typeData = TypeVisual.typeVisuals(notification.type);

    return Dismissible(
      key: Key(notification.notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.cancelled.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.cancelled,
          size: 26,
        ),
      ),
      onDismissed: (_) {
        context.read<NotificationHistoryBloc>().add(
              DeleteNotification(
                userId: userId,
                notificationId: notification.notificationId,
              ),
            );
      },
      child: GestureDetector(
        onTap: () => _onTap(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.divider
                  : AppColors.primary.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──────────────────────────────────────────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeData.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(typeData.icon, color: typeData.color, size: 22),
              ),
              const SizedBox(width: 12),

              // ── Content ───────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + unread dot.
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Body text.
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Type chip + timestamp.
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeData.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeData.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: typeData.color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          // ✅ Use static method via class name, not as instance method
                          TypeVisual.formatTime(notification.timestamp),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tap handler ───────────────────────────────────────────────────────────

  void _onTap(BuildContext context) {
    // 1. Mark as read via NotificationHistoryBloc.
    if (!notification.isRead) {
      context.read<NotificationHistoryBloc>().add(
            MarkNotificationRead(
              userId: userId,
              notificationId: notification.notificationId,
            ),
          );
    }

    // 2. Delegate navigation to the cubit → picked up by BlocListener.
    context.read<NotificationsScreenCubit>().handleCardTap(notification);
  }
}