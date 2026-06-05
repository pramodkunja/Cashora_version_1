import 'package:flutter/material.dart';

/// Cashora design-system token palette. Background gradient stops, an
/// ink scale (text/icon colours), and a neutral surface used for input
/// fills and chips.
class CashoraColors {
  CashoraColors._();

  // Background gradient stops (top → bottom).
  static const Color bgA = Color(0xFFF0E9FF);
  static const Color bgB = Color(0xFFF8F7FF);
  static const Color bgC = Color(0xFFEEF2FF);

  // Ink scale.
  static const Color ink900 = Color(0xFF0F172A);
  static const Color ink700 = Color(0xFF334155);
  static const Color ink500 = Color(0xFF64748B);
  static const Color ink300 = Color(0xFFCBD5E1);
  static const Color ink200 = Color(0xFFE2E8F0);

  // Neutral surface (used as input fill, secondary buttons, chips).
  static const Color surface = Color(0xFFF8FAFC);
}
