import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_colors.dart';
import 'cashora_colors.dart';

/// Full-screen lavender gradient with 2–3 soft radial blooms in the
/// corners. Drop this as the first child of a `Stack` to set the scene.
class AppBackground extends StatelessWidget {
  /// Adds a third bloom on the right-mid for a richer composition
  /// (useful on taller screens / list pages).
  final bool extraBloom;

  const AppBackground({super.key, this.extraBloom = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CashoraColors.bgA,
                CashoraColors.bgB,
                CashoraColors.bgC,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -90.h,
          right: -70.w,
          child: Bloom(size: 280.w, color: AppColors.primary, opacity: 0.20),
        ),
        Positioned(
          top: 40.h,
          left: -60.w,
          child: Bloom(
              size: 200.w, color: AppColors.primaryLight, opacity: 0.26),
        ),
        if (extraBloom)
          Positioned(
            top: 160.h,
            right: -30.w,
            child: Bloom(
                size: 140.w,
                color: AppColors.primaryLight,
                opacity: 0.22),
          ),
      ],
    );
  }
}

/// Soft radial bloom — the decorative blurred circle.
class Bloom extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const Bloom({
    super.key,
    required this.size,
    required this.color,
    this.opacity = 0.20,
  });

  @override
  Widget build(BuildContext context) {
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
