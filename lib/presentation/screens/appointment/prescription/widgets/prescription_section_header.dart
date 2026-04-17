import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class PrescriptionSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const PrescriptionSectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}