import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AppointmentViewStatusBanner extends StatelessWidget {
  final String status;
  const AppointmentViewStatusBanner({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    final Color bg, border, textColor, iconColor;
    final IconData icon;
    final String label;

    if (s == 'completed') {
      bg = AppColors.completedSurface;
      border = AppColors.completed.withValues(alpha: 0.35);
      textColor = AppColors.completed;
      iconColor = AppColors.completed;
      icon = Icons.check_circle_rounded;
      label = 'Appointment Completed';
    } else if (s == 'cancelled') {
      bg = AppColors.cancelledSurface;
      border = AppColors.cancelled.withValues(alpha: 0.35);
      textColor = AppColors.cancelled;
      iconColor = AppColors.cancelled;
      icon = Icons.cancel_rounded;
      label = 'Appointment Cancelled';
    } else if (s == 'confirmed') {
      bg = AppColors.confirmedSurface;
      border = AppColors.confirmed.withValues(alpha: 0.35);
      textColor = AppColors.confirmed;
      iconColor = AppColors.confirmed;
      icon = Icons.event_available_rounded;
      label = 'Appointment Confirmed';
    } else {
      bg = AppColors.pendingSurface;
      border = AppColors.pending.withValues(alpha: 0.35);
      textColor = AppColors.pending;
      iconColor = AppColors.pending;
      icon = Icons.schedule_rounded;
      label = 'Pending Confirmation';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}