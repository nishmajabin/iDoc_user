import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class ThinkingAvatar extends StatelessWidget {
  const ThinkingAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  22,
      height: 22,
      margin: const EdgeInsets.only(right: 8),
      decoration:  BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.layerBlurColor2],
        ),
      ),
      child:  Icon(
        Icons.health_and_safety_rounded,
        color: AppColors.gradientColor,
        size:  12,
      ),
    );
  }
}