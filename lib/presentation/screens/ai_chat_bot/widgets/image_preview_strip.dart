import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class ImagePreviewStrip extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback? onRemove;

  const ImagePreviewStrip({required this.imageBytes, this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              imageBytes,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              margin: const EdgeInsets.all(6),
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.decorColor,
              ),
              child:  Icon(Icons.close, color: AppColors.backgroundColor, size: 16),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.decorColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child:  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, color: AppColors.backgroundColor, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Image attached',
                    style: TextStyle(color: AppColors.backgroundColor, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
