import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/slot_status.dart';
import 'package:idoc_user/core/theme/color.dart';

Color chipBackground(SlotStatus status, bool isSelected) {
  switch (status) {
    case SlotStatus.booked:
      return AppColors.bookedStatusBg; 
    case SlotStatus.past:
      return AppColors.bookedPastBg;
    case SlotStatus.available:
      return isSelected ? AppColors.elevatedBgColor : AppColors.backgroundColor;
  }
}

Color chipBorder(SlotStatus status, bool isSelected) {
  switch (status) {
    case SlotStatus.booked:
      return AppColors.bookedStatusBorder; 
    case SlotStatus.past:
      return AppColors.bookedPastBorder;
    case SlotStatus.available:
      return isSelected ? AppColors.elevatedBgColor : AppColors.bookedPastBg;
  }
}

Color labelColor(SlotStatus status, bool isSelected) {
  switch (status) {
    case SlotStatus.booked:
      return AppColors.bookedLabelColor; 
    case SlotStatus.past:
      return AppColors.bookedPastLabel;
    case SlotStatus.available:
      return isSelected ? AppColors.backgroundColor : AppColors.normalTextColor;
  }
}

Color iconColor(SlotStatus status, bool isSelected) {
  switch (status) {
    case SlotStatus.booked:
      return AppColors.bookedIconColor;
    case SlotStatus.past:
      return AppColors.lightTextColor;
    case SlotStatus.available:
      return isSelected ? AppColors.backgroundColor : AppColors.lightTextColor;
  }
}

IconData leadingIcon(SlotStatus status, bool isSelected) {
  switch (status) {
    case SlotStatus.booked:
      return Icons.lock_outline;
    case SlotStatus.past:
      return Icons.block;
    case SlotStatus.available:
      return isSelected ? Icons.check_circle : Icons.access_time;
  }
}

String badgeLabel(SlotStatus status) {
  switch (status) {
    case SlotStatus.booked:
      return 'Booked';
    case SlotStatus.past:
      return 'Past';
    case SlotStatus.available:
      return '';
  }
}

List<BoxShadow>? chipShadow(SlotStatus status, bool isSelected) {
  if (status == SlotStatus.available && isSelected) {
    return [
      BoxShadow(
        color: AppColors.shadowDark.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
  return null;
}
