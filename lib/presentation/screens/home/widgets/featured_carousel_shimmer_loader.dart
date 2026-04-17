import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedCarouselShimmerLoader extends StatelessWidget {
  const FeaturedCarouselShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}