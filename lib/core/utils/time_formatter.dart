
String formatTimeTo12Hour(String raw) {
  try {
    final parts = raw.trim().split(':');
    if (parts.length < 2) return raw;

    int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    final String period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12; // midnight → 12:xx AM
    } else if (hour > 12) {
      hour -= 12; // 13–23 → 1–11 PM
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  } catch (_) {
    return raw; // graceful fallback — never crash the UI
  }
}

String formatTimeRange(String startTime, String endTime) {
  return '${formatTimeTo12Hour(startTime)} – ${formatTimeTo12Hour(endTime)}';
}