import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';

class GradientTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final List<Color> gradientColors;

  const GradientTitle({
    super.key,
    required this.text,
    this.fontSize = 38,
    this.gradientColors = const [AppColors.signUpgradient1, AppColors.signUpgradient2],
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: AppColors.backgroundColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(
                blurRadius: 15.0,
                color: AppColors.signUpShadow,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}