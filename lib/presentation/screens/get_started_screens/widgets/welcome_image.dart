import 'package:flutter/material.dart';

class WelcomeImage extends StatelessWidget {
  final double height;
  const WelcomeImage({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/get_started.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
