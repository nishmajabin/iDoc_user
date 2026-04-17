import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';

class UserChatDateSeperator extends StatelessWidget {
  final String label;
  const UserChatDateSeperator({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: AppColors.divider)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: AppColors.divider)),
        ],
      ),
    );
  }
}
