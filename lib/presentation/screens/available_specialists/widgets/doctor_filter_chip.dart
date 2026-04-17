import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

Widget buildDoctorFilterChip(
  BuildContext context,
  String label,
  bool isSelected,
  Function(bool) onSelected,
) {
  return FilterChip(
    label: Text(label),
    selected: isSelected,
    onSelected: onSelected,
    selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
    checkmarkColor: AppColors.primaryColor,
    labelStyle: TextStyle(
      color: isSelected ? AppColors.primaryColor : AppColors.lightTextColor,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      fontSize: 13,
    ),
    side: BorderSide(
      color: isSelected ? AppColors.primaryColor : AppColors.lightText,
    ),
  );
}