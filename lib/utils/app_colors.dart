import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6B55CE); // Deep Purple
  static const Color primaryLight = Color(0xFFA695EE); // Light Purple
  static const Color primaryDark = Color(
    0xFF0F172A,
  ); // Slate 900 (Kept for Dark Mode bg)

  // Secondary / Accents
  static const Color surfacePurple = Color(0xFFEBE7FE); // Very light purple
  static const Color cardBackground = Color(
    0xFFF5F3FF,
  ); // Ultra light purple for cards
  static const Color elementPurple = Color(0xFFD7CFFC); // Element purple

  // Backgrounds
  static const Color backgroundLight = Colors.white; // Pure White as requested
  static const Color backgroundAlt = Color(
    0xFFF8FAFC,
  ); // Slate 50 (for slight contrast if needed)
  static const Color white = Colors.white;

  // Text Colors
  static const Color textDark = Color(0xFF0F172A); // Slate 900
  static const Color textSlate = Color(0xFF64748B); // Slate 500
  static const Color textLight = Color(0xFF94A3B8); // Slate 400

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200

  // Status Colors
  static const Color successGreen = Color(0xFF15803D); // Green 700
  static const Color successBg = Color(0xFFDCFCE7); // Green 100

  static const Color errorRed = Color(0xFFB91C1C); // Red 700
  static const Color errorBg = Color(0xFFFEE2E2); // Red 100

  static const Color warningOrange = Color(0xFFB45309); // Amber 700
  static const Color warningBg = Color(0xFFFEF3C7); // Amber 100

  static const Color infoBlue = primary;
  static const Color infoBg = surfacePurple; // Was Blue 100, now matching theme

  // Custom Colors
  static const Color teal = Color(0xFF0F9D88);
  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color amberBorder = Color(0xFFFCD34D);
  static const Color amberIcon = Color(0xFFD97706);
  static const Color mintBg = Color(0xFFECFDF5);

  // Aliases for compatibility
  static const Color success = successGreen;
  static const Color error = errorRed;
  static const Color warning = warningOrange;
  static const Color purple = Color(0xFF9333EA); // Purple 600
  static const Color indigo = Color(0xFF4F46E5); // Indigo 600

  // Deprecated - to be replaced
  static const Color primaryBlue = primary;
}
