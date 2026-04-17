import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/notification_item_model.dart';
import 'package:intl/intl.dart';

class TypeVisual {
  final IconData icon;
  final Color color;
  final String label;

  const TypeVisual({
    required this.icon,
    required this.color,
    required this.label,
  });

 static String formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('h:mm a').format(dt);
  }

  static TypeVisual typeVisuals(NotificationType type) {
    switch (type) {
      case NotificationType.appointmentConfirmed:
        return const TypeVisual(
          icon: Icons.check_circle_rounded,
          color: AppColors.confirmed,
          label: 'Confirmed',
        );
      case NotificationType.chatMessage:
        return const TypeVisual(
          icon: Icons.chat_bubble_rounded,
          color: AppColors.accent,
          label: 'Chat',
        );
      case NotificationType.appointmentReminder:
        return const TypeVisual(
          icon: Icons.alarm_rounded,
          color: AppColors.pending,
          label: 'Reminder',
        );
      case NotificationType.videoCall:
        return const TypeVisual(
          icon: Icons.videocam_rounded,
          color: AppColors.videocall,
          label: 'Video Call',
        );
      case NotificationType.general:
        return const TypeVisual(
          icon: Icons.info_outline_rounded,
          color: AppColors.textSecondary,
          label: 'General',
        );
    }
  }
}
