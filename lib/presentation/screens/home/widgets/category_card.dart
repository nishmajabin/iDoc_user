// lib/presentation/screens/home/widgets/category_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:idoc_user/core/constants/color.dart';

Widget buildCategoryCard(String imageUrl, String label, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Use CachedNetworkImage for better performance
          CachedNetworkImage(
            imageUrl: imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
            placeholder:
                (context, url) => const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            errorWidget:
                (context, url, error) => const Icon(
                  Icons.medical_services,
                  size: 40,
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}
