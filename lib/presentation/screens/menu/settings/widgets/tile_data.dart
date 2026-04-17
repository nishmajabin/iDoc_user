import 'package:flutter/material.dart';

class TileData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const TileData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });
}
