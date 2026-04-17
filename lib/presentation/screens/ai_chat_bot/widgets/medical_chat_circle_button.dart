import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class MedicalChatCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool isActive;

  const MedicalChatCircleButton({
    required this.child,
    this.onTap,
    this.tooltip,
    this.isActive = false,
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
        color: isActive ? AppColors.accent.withValues(alpha: 0.15) : AppColors.inputBg,
        border: Border.all(
          color: isActive ? AppColors.accent : AppColors.divider,
          width: 1.5,
        ),
      ),
      child: Material(
        color: AppColors.transparentColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}