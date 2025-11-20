import 'package:flutter/material.dart';
import 'package:second_project/core/constants/color.dart';

Widget layerBlur(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  return Positioned(
    top: -screenSize.height * 0.2,
    left: -screenSize.width * 0.3,
    right: -screenSize.width * 0.3,
    child: Container(
      height: screenSize.height * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.layerBlurColor1.withValues(alpha: 0.25),
            AppColors.layerBlurColor2.withValues(alpha: 0.1),
            AppColors.layerBlurColor2.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    ),
  );
}
