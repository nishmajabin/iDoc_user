import 'package:flutter/material.dart';

class FeaturedCarouselEmptyFallback extends StatelessWidget {
  const FeaturedCarouselEmptyFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD5EFFF),
            Color(0xFFB3DAF1),
            Color(0xFF8EC5E6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 36,
                color: Color(0xFF4A90D9),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Featured Doctors Yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Top-rated doctors will appear here',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}