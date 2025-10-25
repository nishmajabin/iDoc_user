import 'package:flutter/material.dart';
import 'package:second_project/core/constants/color.dart';

Widget layerBlur(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  return Positioned(
    top: -screenSize.height * 0.03,
    left: -screenSize.width * 0.3,
    right: -screenSize.width * 0.3,
    child: Container(
      height: screenSize.height * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            layerBlurColor1.withValues(alpha: 0.35),
            layerBlurColor2.withValues(alpha: 0.2),
            layerBlurColor2.withValues(alpha: 0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    ),
  );
}
