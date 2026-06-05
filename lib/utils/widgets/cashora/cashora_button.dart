import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';

/// Full-width gradient pill with primary-purple glow shadow.
///
/// Pass an [Rx<bool>] for [loading] if you want it driven by Obx — or
/// pass a plain bool. Use [leadingIcon] / [trailingIcon] for adornments.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;
  final double radius;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 54,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final bool busy = loading;
    return Container(
      width: double.infinity,
      height: height.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: busy
              ? [
                  AppColors.primary.withValues(alpha: 0.55),
                  AppColors.primaryLight.withValues(alpha: 0.55),
                ]
              : [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: busy
            ? const []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.40),
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(radius.r),
          child: Center(
            child: busy
                ? SizedBox(
                    height: 22.h,
                    width: 22.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leadingIcon != null) ...[
                        Icon(leadingIcon, color: Colors.white, size: 20.sp),
                        SizedBox(width: 10.w),
                      ],
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        SizedBox(width: 8.w),
                        Icon(trailingIcon, color: Colors.white, size: 18.sp),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
