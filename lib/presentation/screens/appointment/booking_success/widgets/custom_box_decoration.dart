import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

BoxDecoration cardDecoration() => BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );

ButtonStyle primaryButtonStyle() => ElevatedButton.styleFrom(
      backgroundColor: AppColors.elevatedBgColor,
      foregroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );

ButtonStyle outlineButtonStyle() => OutlinedButton.styleFrom(
      foregroundColor: AppColors.elevatedBgColor,
      side: const BorderSide(color: AppColors.elevatedBgColor, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );