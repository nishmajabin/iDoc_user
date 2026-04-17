import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class SlotSectionFreeBadge extends StatelessWidget {
  const SlotSectionFreeBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count free',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.badgeColor,
        ),
      ),
    );
  }
}
