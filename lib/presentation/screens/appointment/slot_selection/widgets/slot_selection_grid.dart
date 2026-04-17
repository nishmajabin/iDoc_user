import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_chip.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_status_resolver.dart';

class SlotSelectionGrid extends StatelessWidget {
  const SlotSelectionGrid({
    required this.slots,
    required this.selectedSlotId,
    required this.resolver,
    super.key
  });
 
  final List<Map<String, dynamic>> slots;
  final String? selectedSlotId;
  final SlotStatusResolver resolver;
 
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final slotId = slot['slotId'] as String;
        final status = resolver.resolve(slot);
 
        return SlotSelectionChip(
          key: ValueKey(slotId),
          slotId: slotId,
          rawStart: slot['startTime'] as String,
          rawEnd: slot['endTime'] as String,
          status: status,
          isSelected: slotId == selectedSlotId,
        );
      }).toList(),
    );
  }
}