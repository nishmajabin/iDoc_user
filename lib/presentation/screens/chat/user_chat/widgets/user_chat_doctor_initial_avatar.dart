import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';

class UserChatDoctorInitialAvatar extends StatelessWidget {
  final String? name;
  const UserChatDoctorInitialAvatar({this.name, super.key});

  @override
  Widget build(BuildContext context) {
    final initial =
        (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : 'D';
    return Container(
      color: AppColors.primaryLight.withOpacity(0.35),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}