import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AppointmentViewPrescriptionButton extends StatelessWidget {
  final VoidCallback onTap;
  const AppointmentViewPrescriptionButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, color: AppColors.bgColor, size: 20),
            SizedBox(width: 10),
            Text(
              'View Prescription',
              style: TextStyle(
                color: AppColors.bgColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.bottomNavBgColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
