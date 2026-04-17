import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AppointmentViewDivider extends StatelessWidget {
  const AppointmentViewDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.divider);
  }
}