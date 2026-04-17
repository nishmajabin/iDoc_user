import 'package:idoc_user/core/constants/slot_status.dart';

class SlotStatusResolver {
  const SlotStatusResolver({
    required this.isToday,
    required this.selectedDate,
    required this.isSlotInPast,
  });

  final bool isToday;
  final DateTime selectedDate;
  final bool Function(DateTime date, String startTime) isSlotInPast;

  SlotStatus resolve(Map<String, dynamic> slot) {
    final firestoreStatus = slot['status'] as String? ?? 'available';

    if (firestoreStatus == 'booked') return SlotStatus.booked;

    if (isToday && isSlotInPast(selectedDate, slot['startTime'] as String)) {
      return SlotStatus.past;
    }

    return SlotStatus.available;
  }
}