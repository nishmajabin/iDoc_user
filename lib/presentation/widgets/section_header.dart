import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/color.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          GestureDetector(
            onTap: onSeeAllTap,
            child: Text(
              'See All',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
