import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class MedicalChatSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MedicalChatSheetTile(
      {required this.icon, required this.label, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient:  LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.layerBlurColor2],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.gradientColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}