import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Single source of truth for "what does a request status look like?".
///
/// Replaces `_colorForStatus` / `_bgForStatus` / `_statusLabel` helpers
/// previously duplicated across the requestor dashboard, my-requests view,
/// admin approvals, admin history, and request-details layouts.
///
/// Status values accepted (case-insensitive):
///   • `pending`
///   • `approved` / `auto_approved` / `paid`
///   • `rejected`
///   • `clarification`
class RequestStatusVisuals {
  RequestStatusVisuals._();

  // Accent colours
  static const Color _green = AppColors.successGreen;
  static const Color _greenBg = Color(0xFFECFDF5);
  static const Color _red = AppColors.errorRed;
  static const Color _redBg = Color(0xFFFEF2F2);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _amberBg = Color(0xFFFEF3C7);
  static const Color _purpleBg = Color(0xFFF0EDFF);

  /// Foreground / icon / text colour for the given status badge.
  static Color colorFor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'auto_approved':
      case 'paid':
        return _green;
      case 'rejected':
        return _red;
      case 'clarification':
        return AppColors.primary;
      default:
        return _amber;
    }
  }

  /// Background tint for the badge pill.
  static Color bgFor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'auto_approved':
      case 'paid':
        return _greenBg;
      case 'rejected':
        return _redBg;
      case 'clarification':
        return _purpleBg;
      default:
        return _amberBg;
    }
  }

  /// Display label — collapses `auto_approved` → `APPROVED`, keeps
  /// `clarification` as-is, and uppercases everything else.
  static String labelFor(String status) {
    switch (status.toLowerCase()) {
      case 'auto_approved':
        return 'APPROVED';
      case 'clarification':
        return 'CLARIFICATION';
      default:
        return status.toUpperCase();
    }
  }
}
