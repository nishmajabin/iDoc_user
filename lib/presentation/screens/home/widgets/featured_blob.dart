import 'package:flutter/material.dart';

class FeaturedBlob extends StatelessWidget {
  final double size, opacity;
  final Color color;
  const FeaturedBlob({required this.size, required this.color, required this.opacity, super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      );
}