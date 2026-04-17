import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AppointmentCardCancelButton extends StatelessWidget {
  final VoidCallback onTap;
  const AppointmentCardCancelButton({required this.onTap, super.key});
 
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.cancelledSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cancelled.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy_rounded, color: AppColors.cancelled, size: 16),
              SizedBox(width: 8),
              Text('Cancel Appointment',
                  style: TextStyle(
                      color: AppColors.cancelled,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}