import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class BookingSuccessIcon extends StatelessWidget {
  const BookingSuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.elevatedBgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.elevatedBgColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child:  Icon(Icons.check, size: 60, color: AppColors.backgroundColor),
    );
  }
}