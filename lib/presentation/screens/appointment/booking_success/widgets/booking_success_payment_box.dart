import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class BookingSuccessPaymentBox extends StatelessWidget {
  final String paymentId;

  const BookingSuccessPaymentBox({required this.paymentId, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successBgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.successBgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.completed, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment ID:',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  paymentId,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.completed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}