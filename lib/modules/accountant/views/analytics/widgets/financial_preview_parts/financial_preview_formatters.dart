import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shared formatters and palette for the financial preview sub-widgets.
class FinancialPreviewFormatters {
  FinancialPreviewFormatters._();

  /// Category color palette reused by the hero card, top categories
  /// breakdown and the transactions list.
  static const List<Color> categoryColors = [
    Color(0xFF6B55CE),
    Color(0xFF10B981),
    Color(0xFFF97316),
    Color(0xFF0EA5E9),
    Color(0xFFEC4899),
    Color(0xFFEAB308),
    Color(0xFF64748B),
  ];

  static String prettyCategory(String raw) {
    if (raw.isEmpty) return 'Uncategorised';
    return raw
        .split('_')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  static String formatMoney(double value) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return formatter.format(value);
  }

  static String formatReadableDate(String raw) {
    if (raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }
}
