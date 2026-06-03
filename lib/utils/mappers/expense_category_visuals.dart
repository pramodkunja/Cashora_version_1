import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Single source of truth for "what does an expense category look like?".
///
/// Replaces `_iconForCategory` / `_iconColorForCategory` / `_iconBgForCategory`
/// (and `_iconFor` / `_iconColorFor` / `_iconBgFor` variants) previously
/// duplicated across `accountant_home_view`, `requestor_dashboard_view`,
/// `cash_flow_history_view`, and several payment-flow screens.
///
/// Matching is keyword-based (case-insensitive `String.contains`) so values
/// like `'office_supplies'`, `'travel_expense'`, `'client_meeting'` all
/// resolve correctly.
class ExpenseCategoryVisuals {
  ExpenseCategoryVisuals._();

  // Accent colours
  static const Color _green = AppColors.successGreen;
  static const Color _greenBg = Color(0xFFECFDF5);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _amberBg = Color(0xFFFEF3C7);
  static const Color _blue = Color(0xFF0EA5E9);
  static const Color _blueBg = Color(0xFFE0F2FE);
  static const Color _pink = Color(0xFFEC4899);
  static const Color _pinkBg = Color(0xFFFCE7F3);
  static const Color _purpleBg = Color(0xFFF0EDFF);

  static IconData iconFor(String category) {
    final c = category.toLowerCase();
    if (c.contains('office') || c.contains('supplies')) {
      return Icons.shopping_bag_rounded;
    }
    if (c.contains('travel') || c.contains('flight')) {
      return Icons.flight_rounded;
    }
    if (c.contains('meal') ||
        c.contains('food') ||
        c.contains('client_meeting')) {
      return Icons.restaurant_rounded;
    }
    if (c.contains('software')) return Icons.code_rounded;
    if (c.contains('hardware')) return Icons.devices_other_rounded;
    if (c.contains('transport') || c.contains('taxi')) {
      return Icons.directions_car_rounded;
    }
    return Icons.receipt_long_rounded;
  }

  static Color colorFor(String category) {
    final c = category.toLowerCase();
    if (c.contains('office') || c.contains('supplies')) return _pink;
    if (c.contains('travel') || c.contains('flight')) return _blue;
    if (c.contains('meal') ||
        c.contains('food') ||
        c.contains('client_meeting')) {
      return _amber;
    }
    if (c.contains('software') || c.contains('hardware')) {
      return AppColors.primary;
    }
    if (c.contains('transport') || c.contains('taxi')) return _green;
    return AppColors.primary;
  }

  static Color bgFor(String category) {
    final c = category.toLowerCase();
    if (c.contains('office') || c.contains('supplies')) return _pinkBg;
    if (c.contains('travel') || c.contains('flight')) return _blueBg;
    if (c.contains('meal') ||
        c.contains('food') ||
        c.contains('client_meeting')) {
      return _amberBg;
    }
    if (c.contains('software') || c.contains('hardware')) return _purpleBg;
    if (c.contains('transport') || c.contains('taxi')) return _greenBg;
    return _purpleBg;
  }
}
