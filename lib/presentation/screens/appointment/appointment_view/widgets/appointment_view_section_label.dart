import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AppointmentViewSectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  const AppointmentViewSectionLabel({required this.icon, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
