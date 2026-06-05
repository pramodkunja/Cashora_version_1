import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';

/// Pastel gradient background layer with soft corner blooms.
/// Sits behind the entire login screen.
class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  // ── Light palette tuned for this screen ───────────────────────────────
  static const Color _bgA = Color(0xFFF0E9FF); // top
  static const Color _bgB = Color(0xFFF8F7FF); // mid
  static const Color _bgC = Color(0xFFEEF2FF); // bottom

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgA, _bgB, _bgC],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Soft corner blooms — concentrated in the top hero zone for visual
        // depth. Third bloom on the right-mid adds asymmetry/richness.
        Positioned(
          top: -90.h,
          right: -70.w,
          child: _bloom(280.w, AppColors.primary, 0.20),
        ),
        Positioned(
          top: 40.h,
          left: -60.w,
          child: _bloom(200.w, AppColors.primaryLight, 0.28),
        ),
        Positioned(
          top: 140.h,
          right: -30.w,
          child: _bloom(140.w, AppColors.primaryLight, 0.22),
        ),
      ],
    );
  }

  Widget _bloom(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
