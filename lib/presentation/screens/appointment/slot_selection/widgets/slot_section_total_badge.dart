import 'package:flutter/material.dart';

class SlotSectionTotalBadge extends StatelessWidget {
  const SlotSectionTotalBadge({required this.count, required this.color, super.key});
 
  final int count;
  final Color color;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}