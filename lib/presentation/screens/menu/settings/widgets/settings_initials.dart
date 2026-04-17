import 'package:flutter/material.dart';

class SettingsInitials extends StatelessWidget {
  final String text;
  const SettingsInitials(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white.withValues(alpha: 0.18),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      );
}