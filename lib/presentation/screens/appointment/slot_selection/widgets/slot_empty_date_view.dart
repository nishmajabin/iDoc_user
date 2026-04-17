import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class SlotEmptyDateView extends StatelessWidget {
  const SlotEmptyDateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: AppColors.lightText),
          const SizedBox(height: 16),
          Text(
            'No slots for this date',
            style: TextStyle(color: AppColors.lightTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}