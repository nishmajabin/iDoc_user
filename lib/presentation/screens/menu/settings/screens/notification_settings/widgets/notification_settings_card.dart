import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class NotificationSettingsCard extends StatelessWidget {
  final List<Widget> children;
  const NotificationSettingsCard({required this.children, super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(children: children),
        ),
      );
}
