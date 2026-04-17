import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class ChatInputAttachButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool hasImage;

  const ChatInputAttachButton({this.onTap, required this.hasImage, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hasImage
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.bgColor,
          border: Border.all(
            color: hasImage ? AppColors.accent : AppColors.dividerColor,
            width: 1.5,
          ),
        ),
        child: Icon(
          hasImage ? Icons.image_rounded : Icons.add_photo_alternate_outlined,
          color: hasImage ? AppColors.accent : AppColors.skipColor,
          size: 20,
        ),
      ),
    );
  }
}