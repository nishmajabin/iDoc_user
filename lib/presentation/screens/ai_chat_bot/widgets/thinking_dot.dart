import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class ThinkingDot extends StatelessWidget {
  final double offset;
  const ThinkingDot({required this.offset, super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width:  7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent,
        ),
      ),
    );
  }
}