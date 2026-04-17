import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class SlotSelectionTodayNotice extends StatelessWidget {
  const SlotSelectionTodayNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cancelledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cancelledColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.slotDecor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Only future time slots are available for booking',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.slotText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
