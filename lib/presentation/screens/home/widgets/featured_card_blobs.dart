import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_blob.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_plus_icon.dart';

class FeaturedCardBlobs extends StatelessWidget {
  const FeaturedCardBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -25,
            left: -20,
            child: FeaturedBlob(size: 100, color: Color(0xFF7AB8DB), opacity: 0.25),
          ),
          Positioned(
            bottom: -30,
            left: 100,
            child: FeaturedBlob(size: 80, color: Color(0xFF94CEE8), opacity: 0.20),
          ),
          Positioned(
            top: 20,
            right: 100,
            child: FeaturedBlob(size: 14, color: Colors.white, opacity: 0.5),
          ),
          Positioned(
            bottom: 40,
            left: 60,
            child: FeaturedPlusIcon(size: 16, opacity: 0.5),
          ),
          Positioned(
            top: 50,
            left: 170,
            child: FeaturedPlusIcon(size: 12, opacity: 0.4),
          ),
        ],
      ),
    );
  }
}
