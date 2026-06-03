/// Centralized currency formatting.
///
/// Extracted from `_formatInr` helpers previously duplicated across
/// `admin_dashboard_view`, `accountant_home_view`, `requestor_dashboard_view`,
/// `requestor_dashboard` recent list, and several payment-flow screens.
library;

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Indian-grouping integer rupees: `230000 → "2,30,000"`, `12345 → "12,345"`,
  /// `999 → "999"`. Decimals are truncated so amount headlines don't run
  /// out of horizontal room on small screens.
  static String inr(double v) {
    final whole = v.truncate();
    final digits = whole.toString();
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    String rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }

  /// `₹2,30,000` — convenience wrapper that prepends the rupee sign.
  static String inrWithSymbol(double v) => '₹${inr(v)}';

  /// Strict two-decimal version: `230000.5 → "2,30,000.50"`. Use this when
  /// you need to preserve cents (e.g. bill confirmation, receipt totals).
  static String inrPrecise(double v) {
    final whole = v.truncate().toDouble();
    final frac = (v - whole).abs();
    final fracStr = (frac * 100).round().toString().padLeft(2, '0');
    return '${inr(whole)}.$fracStr';
  }
}
