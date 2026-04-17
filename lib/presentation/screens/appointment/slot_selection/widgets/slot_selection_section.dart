import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/slot_status.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_section_header.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_grid.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_status_resolver.dart';

class SlotSelectionSection extends StatelessWidget {
  const SlotSelectionSection({
    required this.title,
    required this.slots,
    required this.selectedSlotId,
    required this.icon,
    required this.color,
    required this.isToday,
    required this.selectedDate,
    required this.isSlotInPast,
    super.key,
  });
 
  final String title;
  final List<Map<String, dynamic>> slots;
  final String? selectedSlotId;
  final IconData icon;
  final Color color;
  final bool isToday;
  final DateTime selectedDate;
  final bool Function(DateTime date, String startTime) isSlotInPast;
 
  @override
  Widget build(BuildContext context) {
    final resolver = SlotStatusResolver(
      isToday: isToday,
      selectedDate: selectedDate,
      isSlotInPast: isSlotInPast,
    );
 
    final bookableCount = slots
        .where((s) => resolver.resolve(s) == SlotStatus.available)
        .length;
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlotSectionHeader(
          title: title,
          icon: icon,
          color: color,
          totalCount: slots.length,
          bookableCount: bookableCount,
        ),
        const SizedBox(height: 12),
        SlotSelectionGrid(
          slots: slots,
          selectedSlotId: selectedSlotId,
          resolver: resolver,
        ),
      ],
    );
  }
}