import 'package:flutter/material.dart';

class EditProfileAppBarBackground extends StatelessWidget {
  const EditProfileAppBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF052C40),
            Color(0xFF0A4A6B),
            Color(0xFF0096C7),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}
