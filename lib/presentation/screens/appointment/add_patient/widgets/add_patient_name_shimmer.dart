import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AddPatientNameShimmer extends StatelessWidget {
  const AddPatientNameShimmer({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.shimmerBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.person_outline, color: AppColors.disabledIconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.shimmerDecorColor,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}