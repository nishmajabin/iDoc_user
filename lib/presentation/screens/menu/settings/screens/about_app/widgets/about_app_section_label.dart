import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AboutAppSectionLabel extends StatelessWidget {
  final String text;
  const AboutAppSectionLabel(this.text, {super.key});
  
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
      );
}