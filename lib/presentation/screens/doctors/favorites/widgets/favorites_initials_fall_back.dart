import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesInitialsFallBack extends StatelessWidget {
  final String initials;
  const FavoritesInitialsFallBack({required this.initials, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
