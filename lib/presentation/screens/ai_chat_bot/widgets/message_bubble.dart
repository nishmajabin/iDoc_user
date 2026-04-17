import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/medical_chat_message.dart';

class MessageBubble extends StatelessWidget {
  final MedicalChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 56 : 0,
        right: isUser ? 0 : 56,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAiLabel(),
          const SizedBox(height: 4),
          _buildBubble(context),
          const SizedBox(height: 4),
          _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildAiLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient:  LinearGradient(
              colors: [AppColors.linearGradientColor, AppColors.layerBlurColor2],
            ),
          ),
          child:  Icon(Icons.health_and_safety_rounded,
              color: AppColors.gradientColor, size: 12),
        ),
        const SizedBox(width: 6),
        const Text(
          'MedBot',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78),
      decoration: BoxDecoration(
        color: message.isError
            ? AppColors.errorBg
            : message.isUser
                ? AppColors.userBubble
                : AppColors.aiBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft:
              message.isUser ? const Radius.circular(20) : const Radius.circular(4),
          bottomRight:
              message.isUser ? const Radius.circular(4) : const Radius.circular(20),
        ),
        border: message.isError
            ? Border.all(color: AppColors.errorText.withValues(alpha: 0.3))
            : message.isUser
                ? null
                : Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image thumbnail
          if (message.hasImage)
            Stack(
              children: [
                Image.memory(
                  message.imageBytes!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: AppColors.divider,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: AppColors.textSecondary),
                    ),
                  ),
                ),
                // Gradient overlay at bottom of image
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.transparentColor,
                          AppColors.shadowDark.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Error icon + text
          if (message.isError && message.hasText)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.errorText, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message.text!,
                      style: const TextStyle(
                        color: AppColors.errorText,
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )

          // Normal text
          else if (message.hasText)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: SelectableText(
                message.text!,
                style: TextStyle(
                  color: message.isUser
                      ? AppColors.bgColor
                      : AppColors.textPrimary,
                  fontSize: 14.5,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    if (message.timestamp == null) return const SizedBox.shrink();
    final h = message.timestamp!.hour.toString().padLeft(2, '0');
    final m = message.timestamp!.minute.toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.hasImage)
          const Icon(Icons.image_outlined, size: 10, color: AppColors.textSecondary),
        if (message.hasImage) const SizedBox(width: 3),
        Text(
          '$h:$m',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
