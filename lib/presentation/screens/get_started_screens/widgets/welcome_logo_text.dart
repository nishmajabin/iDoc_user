import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/constants/color.dart';

class WelcomeLogoText extends StatelessWidget {
  const WelcomeLogoText({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [const Color(0xFF0077B6), AppColors.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        'iDOC',
        textAlign: TextAlign.center,
        style: GoogleFonts.passionOne(
          color: Colors.white,
          fontSize: 45,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.5,
          shadows: const [
            Shadow(
              blurRadius: 2,
              color: Color.fromRGBO(0, 0, 0, 0.3),
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}
