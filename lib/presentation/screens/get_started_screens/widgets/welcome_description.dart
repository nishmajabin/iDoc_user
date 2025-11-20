import 'package:flutter/material.dart';

class WelcomeDescription extends StatelessWidget {
  const WelcomeDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Dedicated to advancing healthcare standards in communities.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 17,
        height: 1.7,
        color: Color(0xFF333333),
      ),
    );
  }
}
