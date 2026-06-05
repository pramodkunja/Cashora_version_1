import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';
import '../../controllers/splash_controller.dart';

/// Bottom hairline progress bar with the "PREPARING YOUR WORKSPACE" label.
/// Reads progress from [SplashController].
class SplashLoader extends StatelessWidget {
  const SplashLoader({
    super.key,
    required this.controller,
    this.trackColor = const Color(0xFFE2E1F5),
    this.labelColor = const Color(0xFF64748B),
  });

  final SplashController controller;
  final Color trackColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            tween: Tween<double>(
              begin: 0,
              end: controller.progress.value,
            ),
            builder: (context, value, _) {
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(1.h),
                    ),
                  ),
                  // Fill with primary gradient + glow
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 2.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1.h),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.50),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'PREPARING YOUR WORKSPACE',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}
