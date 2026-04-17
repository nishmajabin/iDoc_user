import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class StatusStyle {
  final Color color, surface;
  final String label;
  final IconData icon;
  const StatusStyle({
    required this.color,
    required this.surface,
    required this.label,
    required this.icon,
  });
 
  static StatusStyle of(String status) => switch (status.toLowerCase()) {
        'completed' => const StatusStyle(
            color: AppColors.completed,
            surface: AppColors.completedSurface,
            label: 'Completed',
            icon: Icons.check_circle_rounded),
        'cancelled' => const StatusStyle(
            color: AppColors.cancelled,
            surface: AppColors.cancelledSurface,
            label: 'Cancelled',
            icon: Icons.cancel_rounded),
        'confirmed' => const StatusStyle(
            color: AppColors.confirmed,
            surface: AppColors.confirmedSurface,
            label: 'Confirmed',
            icon: Icons.event_available_rounded),
        _ => const StatusStyle(
            color: AppColors.pending,
            surface: AppColors.pendingSurface,
            label: 'Pending',
            icon: Icons.schedule_rounded),
      };
}
 