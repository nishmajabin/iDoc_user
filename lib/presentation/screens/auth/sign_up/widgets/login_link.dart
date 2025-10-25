import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginLink extends StatelessWidget {
  final VoidCallback onTap;

  const LoginLink({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: GoogleFonts.poppins(
            color: const Color(0xFF555555),
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: 'Login',
              style: GoogleFonts.poppins(
                color: const Color(0xFF0D72A6),
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}