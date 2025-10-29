import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:second_project/core/constants/color.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.onBackPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 200,
        color: const Color(0xFF6AD2FF),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: primaryColor,
              onPressed: onBackPressed,
            ),
            Text(
              'Profile',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_note_outlined),
                  color: primaryColor,
                  onPressed: onEditPressed,
                ),
                Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}