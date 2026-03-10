import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int totalRatings;
  final double size;
  final bool showCount;

  const RatingDisplay({
    super.key,
    required this.rating,
    required this.totalRatings,
    this.size = 20,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (totalRatings == 0) {
      return Text(
        'Be the first person to rate',
        style: TextStyle(
          fontSize: size * 0.7, // Keep scale relative to requested size
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(
              Icons.star,
              color: Colors.amber,
              size: size,
            );
          } else if (index < rating && rating % 1 != 0) {
            return Icon(
              Icons.star_half,
              color: Colors.amber,
              size: size,
            );
          } else {
            return Icon(
              Icons.star_border,
              color: Colors.amber,
              size: size,
            );
          }
        }),
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            '${rating.toStringAsFixed(1)} ($totalRatings)',
            style: TextStyle(
              fontSize: size * 0.7,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}