import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class MyAppointmentEmptyState extends StatelessWidget {
  final bool isUpcoming;

  const MyAppointmentEmptyState({required this.isUpcoming, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isUpcoming
                    ? Icons.event_available_rounded
                    : Icons.history_rounded,
                size: 44,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isUpcoming
                  ? 'No Upcoming Appointments'
                  : 'No Past Appointments',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isUpcoming
                  ? 'Your upcoming scheduled visits will appear here.'
                  : 'Your appointment history will show up here.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
