import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_legend_item.dart';

class SlotSelectionLegend extends StatelessWidget {
  const SlotSelectionLegend({super.key});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children:  [
        SlotSelectionLegendItem(
          color: AppColors.backgroundColor,
          borderColor: AppColors.lightText,
          label: 'Available',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.elevatedBgColor,
        ),
        SlotSelectionLegendItem(
          color: AppColors.bookedStatusBg,
          borderColor: AppColors.bookedStatusBorder,
          label: 'Booked',
          icon: Icons.lock_outline,
          iconColor: AppColors.bookedIconColor,
        ),
        SlotSelectionLegendItem(
          color: AppColors.bookedPastBg,
          borderColor: AppColors.bookedPastBorder,
          label: 'Past',
          icon: Icons.block,
          iconColor: AppColors.bookedPastBorder,
        ),
      ],
    );
  }
}
