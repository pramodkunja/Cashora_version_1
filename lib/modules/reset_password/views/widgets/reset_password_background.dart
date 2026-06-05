import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';

class ResetPasswordBackground extends StatelessWidget {
  const ResetPasswordBackground({super.key});

  static const Color _bgTop = Color(0xFFF8F7FF);
  static const Color _bgBottom = Color(0xFFEEF2FF);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgTop, _bgBottom],
            ),
          ),
        ),
        Positioned(
          top: -80.h,
          right: -60.w,
          child: _blob(260.w, AppColors.primary, 0.18),
        ),
        Positioned(
          bottom: -100.h,
          left: -80.w,
          child: _blob(300.w, AppColors.primaryLight, 0.22),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}
