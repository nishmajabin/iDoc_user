import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/menu/settings/widgets/settings_tile.dart';
import 'package:idoc_user/presentation/screens/menu/settings/widgets/tile_data.dart';

class SettingsCard extends StatelessWidget {
  final List<TileData> items;
  const SettingsCard({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Column(
          children: List.generate(
            items.length,
            (i) => Column(
              children: [
                SettingsTile(data: items[i]),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 16,
                    color: AppColors.divider,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}