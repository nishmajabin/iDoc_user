import 'package:flutter/foundation.dart';

@immutable
class SlotOrganizer {
  const SlotOrganizer._();

  // ── Date list ────────────────────────────────────────────────────────────

  static List<DateTime> buildAvailableDates(
    List<Map<String, dynamic>> slots,
  ) {
    final uniqueDates = <DateTime>{};

    for (final slot in slots) {
      final d = slot['date'] as DateTime;
      uniqueDates.add(DateTime(d.year, d.month, d.day));
    }

    return uniqueDates.toList()..sort((a, b) => a.compareTo(b));
  }

  // ── Slot filtering ───────────────────────────────────────────────────────

  static List<Map<String, dynamic>> slotsForDate(
    List<Map<String, dynamic>> slots,
    DateTime selectedDate,
  ) {
    final normalised = _normalise(selectedDate);

    return slots.where((slot) {
      final d = slot['date'] as DateTime;
      return _normalise(d).isAtSameMomentAs(normalised);
    }).toList();
  }

  // ── Time-period grouping ─────────────────────────────────────────────────

  static SlotGroups groupByPeriod(List<Map<String, dynamic>> slots) {
    final morning = <Map<String, dynamic>>[];
    final afternoon = <Map<String, dynamic>>[];
    final evening = <Map<String, dynamic>>[];

    for (final slot in slots) {
      final hour = int.parse((slot['startTime'] as String).split(':')[0]);

      if (hour < 12) {
        morning.add(slot);
      } else if (hour < 17) {
        afternoon.add(slot);
      } else {
        evening.add(slot);
      }
    }

    return SlotGroups(morning: morning, afternoon: afternoon, evening: evening);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// Value object that holds the three time-period slot buckets produced by
/// [SlotOrganizer.groupByPeriod].
@immutable
class SlotGroups {
  const SlotGroups({
    required this.morning,
    required this.afternoon,
    required this.evening,
  });

  final List<Map<String, dynamic>> morning;
  final List<Map<String, dynamic>> afternoon;
  final List<Map<String, dynamic>> evening;

  bool get isEmpty =>
      morning.isEmpty && afternoon.isEmpty && evening.isEmpty;
}