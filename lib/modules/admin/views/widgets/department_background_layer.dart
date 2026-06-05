import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';

/// Pastel gradient background with two radial bloom highlights.
/// Sits behind every section of the department list screen.
class DepartmentBackgroundLayer extends StatelessWidget {
  static const Color bgA = Color(0xFFF0E9FF);
  static const Color bgB = Color(0xFFF8F7FF);
  static const Color bgC = Color(0xFFEEF2FF);

  const DepartmentBackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgA, bgB, bgC],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -90.h,
          right: -70.w,
          child: _Bloom(size: 280.w, color: AppColors.primary, opacity: 0.18),
        ),
        Positioned(
          top: 40.h,
          left: -60.w,
          child: _Bloom(
            size: 200.w,
            color: AppColors.primaryLight,
            opacity: 0.24,
          ),
        ),
      ],
    );
  }
}

class _Bloom extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Bloom({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}
