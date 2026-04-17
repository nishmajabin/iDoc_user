import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class BookingSuccessDetailRow extends StatelessWidget{
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const BookingSuccessDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.elevatedBgColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.elevatedBgColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.lightTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.normalTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



