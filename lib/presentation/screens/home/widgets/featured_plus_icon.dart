import 'package:flutter/material.dart';

class FeaturedPlusIcon extends StatelessWidget {
  final double size, opacity;
  const FeaturedPlusIcon({required this.size, required this.opacity, super.key});

  @override
  Widget build(BuildContext context) => Icon(
        Icons.add,
        size: size,
        color: const Color(0xFF5BA0C8).withValues(alpha: opacity),
      );
}