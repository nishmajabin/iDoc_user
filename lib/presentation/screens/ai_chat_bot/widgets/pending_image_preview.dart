import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class PendingImagePreview extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onRemove;

  const PendingImagePreview(
      {required this.imageBytes, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              imageBytes,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              margin: const EdgeInsets.all(6),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.shadowDark.withValues(alpha:0.65),
              ),
              child:  Icon(Icons.close, color: AppColors.bgColor, size: 14),
            ),
          ),
          // Badge
          Positioned(
            bottom: 7,
            left: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.shadowDark.withValues(alpha:0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child:  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, color: AppColors.gradientColor, size: 11),
                  SizedBox(width: 4),
                  Text('Image attached',
                      style: TextStyle(color: AppColors.gradientColor, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
