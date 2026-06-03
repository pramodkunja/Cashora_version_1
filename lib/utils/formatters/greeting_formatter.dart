/// Time-of-day greeting helper.
///
/// Extracted from `GreetingFormatter.timeOfDay()` previously duplicated across the three
/// dashboards (admin / accountant home / requestor dashboard).
library;

class GreetingFormatter {
  GreetingFormatter._();

  /// Returns `"Morning"`, `"Afternoon"`, or `"Evening"` based on the
  /// device clock. Pair with `'Good ${GreetingFormatter.timeOfDay()}'`.
  static String timeOfDay({DateTime? now}) {
    final h = (now ?? DateTime.now()).hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  /// `"Good Morning"` / `"Good Afternoon"` / `"Good Evening"`.
  static String greeting({DateTime? now}) => 'Good ${timeOfDay(now: now)}';
}
