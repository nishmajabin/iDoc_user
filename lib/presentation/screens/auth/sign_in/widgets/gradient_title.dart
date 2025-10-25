import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final List<Color> gradientColors;

  const GradientTitle({
    super.key,
    required this.text,
    this.fontSize = 38,
    this.gradientColors = const [Color(0xFF052C40), Color(0xFF0D72A6)],
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
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(
                blurRadius: 15.0,
                color: Color.fromRGBO(13, 114, 166, 0.4),
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}