import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class PrefilledNameCard extends StatelessWidget {
  final TextEditingController nameController;
 
  const PrefilledNameCard({required this.nameController, super.key});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.elevatedBgColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.elevatedBgColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Name',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.lightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                // Use ValueListenableBuilder so the text auto-updates if the
                // controller value changes without us needing a full rebuild.
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: nameController,
                  builder: (_, value, __) => Text(
                    value.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.normalTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.elevatedBgColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.verified_user_outlined,
                  size: 12,
                  color: AppColors.elevatedBgColor,
                ),
                SizedBox(width: 4),
                Text(
                  'From Profile',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.elevatedBgColor,
                    fontWeight: FontWeight.w500,
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