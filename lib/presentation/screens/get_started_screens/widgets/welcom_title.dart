import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'IMPROVE YOUR LIFESTYLE',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E1E1E),
        shadows: const [
          Shadow(
            blurRadius: 10,
            color: Color.fromRGBO(14, 31, 84, 0.392),
            offset: Offset(0, 4),
          )
        ],
      ),
    );
  }
}
