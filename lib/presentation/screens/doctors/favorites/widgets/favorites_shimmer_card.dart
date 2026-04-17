import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_shimmer_box.dart';

class FavoritesShimmerCard extends StatelessWidget {
  const FavoritesShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FavoritesShimmerBox(h: 100, w: 82, radius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: FavoritesShimmerBox(h: 14, w: double.infinity)),
                    const SizedBox(width: 10),
                    FavoritesShimmerBox(h: 34, w: 34, radius: 10),
                  ],
                ),
                const SizedBox(height: 8),
                FavoritesShimmerBox(h: 11, w: 120),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FavoritesShimmerBox(h: 26, w: 80),
                    const SizedBox(width: 8),
                    FavoritesShimmerBox(h: 26, w: 90),
                  ],
                ),
                const SizedBox(height: 12),
                FavoritesShimmerBox(h: 36, w: double.infinity, radius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
