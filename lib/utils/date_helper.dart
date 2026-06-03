class DateHelper {
  static String getFormattedDate() {
    final now = DateTime.now();
    final day = _weekdays[now.weekday - 1];
    final month = _months[now.month - 1];
    return '$day, ${now.day} $month';
  }

  static String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    try {
      final date = _parseUtcThenLocal(isoDate);
      final day = _weekdays[date.weekday - 1];
      final month = _months[date.month - 1];
      return '$day, ${date.day} $month';
    } catch (e) {
      return isoDate;
    }
  }

  /// Format a backend ISO timestamp as a chat-style date + time, e.g.
  /// `Today, 5:22 AM` / `Yesterday, 4:30 PM` / `27 Apr, 5:22 AM` /
  /// `27 Apr 2025, 5:22 AM` when the year differs.
  ///
  /// Returns [fallback] when the input is empty or cannot be parsed.
  /// FastAPI serializes UTC timestamps without a 'Z' suffix; `DateTime.parse`
  /// would otherwise treat them as local time and the display would be off
  /// by the user's UTC offset. This helper appends a 'Z' when no timezone
  /// marker is present and converts to local before formatting.
  static String formatDateTime(
    String? isoDate, {
    String fallback = 'N/A',
  }) {
    if (isoDate == null || isoDate.isEmpty) return fallback;
    try {
      final dt = _parseUtcThenLocal(isoDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final that = DateTime(dt.year, dt.month, dt.day);
      final diffDays = today.difference(that).inDays;

      final time = _formatClock(dt);

      if (diffDays == 0) return 'Today, $time';
      if (diffDays == 1) return 'Yesterday, $time';
      final month = _months[dt.month - 1];
      if (dt.year == now.year) return '${dt.day} $month, $time';
      return '${dt.day} $month ${dt.year}, $time';
    } catch (_) {
      return fallback;
    }
  }

  /// Parse an ISO timestamp from the backend.
  ///
  /// FastAPI emits naive timestamps (no `Z`, no `±HH:MM`) — those represent
  /// the server's clock, NOT UTC. We parse them as-is so the displayed time
  /// matches what the backend recorded.
  ///
  /// If the string DOES carry a timezone marker, we honour it and convert
  /// to the device's local zone.
  static DateTime _parseUtcThenLocal(String raw) {
    final hasZone = raw.endsWith('Z') ||
        RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(raw);
    final parsed = DateTime.parse(raw);
    return hasZone ? parsed.toLocal() : parsed;
  }

  static String _formatClock(DateTime dt) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h12:$mm $ampm';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}
