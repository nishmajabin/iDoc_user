import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class SlotSelectionLegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;
  final IconData icon;
  final Color iconColor;

  const SlotSelectionLegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
    required this.icon,
    required this.iconColor,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.lightTextColor2,
            ),
          ),
        ],
      ),
    );
  }
}
