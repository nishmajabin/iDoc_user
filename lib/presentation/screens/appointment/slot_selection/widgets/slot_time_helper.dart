/// Pure helper for slot time calculations.
///
/// Extracted from the widget layer so the logic can be tested without
/// a Flutter environment and reused across screens if needed.
abstract final class SlotTimeHelper {
  /// Returns `true` when the slot starting at [startTime] on [slotDate]
  /// is considered to be in the past (more than 5 minutes ago).
  ///
  /// [startTime] is expected in `HH:mm` 24-hour format, optionally suffixed
  /// with `AM`/`PM` (legacy support). Returns `true` on any parse failure so
  /// that invalid slots are conservatively treated as unselectable.
  static bool isSlotInPast(DateTime slotDate, String startTime) {
    try {
      final cleaned = startTime.replaceAll(RegExp(r'[AP]M'), '').trim();
      final parts = cleaned.split(':');

      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (startTime.contains('PM') && hour != 12) hour += 12;
      if (startTime.contains('AM') && hour == 12) hour = 0;

      final slotDateTime = DateTime(
        slotDate.year,
        slotDate.month,
        slotDate.day,
        hour,
        minute,
      );

      return slotDateTime.isBefore(
        DateTime.now().add(const Duration(minutes: 5)),
      );
    } catch (_) {
      return true;
    }
  }
}