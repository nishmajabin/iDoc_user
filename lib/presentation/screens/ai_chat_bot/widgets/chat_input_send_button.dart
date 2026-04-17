import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class ChatInputSendButton extends StatelessWidget {
  final bool canSend;
  final bool isLoading;
  final VoidCallback onTap;

  const ChatInputSendButton({
    required this.canSend,
    required this.isLoading,
    required this.onTap,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: canSend ? AppColors.primaryColor : AppColors.dividerColor,
        boxShadow: canSend
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
            : null,
      ),
      child: Material(
        color: AppColors.transparentColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: canSend ? onTap : null,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.skipColor,
                    ),
                  )
                :  Icon(
                    Icons.send_rounded,
                    color: AppColors.gradientColor,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}