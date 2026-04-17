import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserChatErrorView extends StatelessWidget {
  final String message;
  const UserChatErrorView({required this.message, super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFFE05C5C),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}