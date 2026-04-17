import 'package:flutter/material.dart';

class FeaturedRatingBadge extends StatelessWidget {
  final double averageRating;
  final int totalRatings;

  const FeaturedRatingBadge({
    super.key,
    required this.averageRating,
    required this.totalRatings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
          const SizedBox(width: 3),
          Text(
            averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '($totalRatings)',
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}