import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class BookingSuccessInfoCard extends StatelessWidget {
  const BookingSuccessInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please arrive 10 minutes before your appointment time',
              style: TextStyle(fontSize: 13, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}