import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_section_free_badge.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_section_total_badge.dart';

class SlotSectionHeader extends StatelessWidget {
  const SlotSectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.totalCount,
    required this.bookableCount,
    super.key,
  });
 
  final String title;
  final IconData icon;
  final Color color;
  final int totalCount;
  final int bookableCount;
 
  bool get _hasBookedSlots => bookableCount < totalCount;
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        SlotSectionTotalBadge(count: totalCount, color: color),
        if (_hasBookedSlots) ...[
          const SizedBox(width: 6),
          SlotSectionFreeBadge(count: bookableCount),  
        ],
      ],
    );
  }
}