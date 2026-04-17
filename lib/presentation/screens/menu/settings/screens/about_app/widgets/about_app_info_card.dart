import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/about_app/widgets/about_app_info_row.dart';

class AboutAppInfoCard extends StatelessWidget {
  final List<AboutAppInfoRow> items;
  const AboutAppInfoCard({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: List.generate(items.length, (i) => Column(
            children: [
              items[i],
              if (i < items.length - 1)
                const Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 16,
                    color: AppColors.divider),
            ],
          )),
        ),
      ),
    );
  }
}