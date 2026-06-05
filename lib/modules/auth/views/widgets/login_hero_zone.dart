import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import 'login_entrance_wrap.dart';

/// Top hero zone: brand lockup + welcome headline + subtitle.
/// Lives above the white form sheet.
class LoginHeroZone extends StatelessWidget {
  const LoginHeroZone({super.key});

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 20.h, 28.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoginEntranceWrap(
            duration: const Duration(milliseconds: 600),
            child: _buildBrandLockup(),
          ),
          SizedBox(height: 26.h),
          LoginEntranceWrap(
            duration: const Duration(milliseconds: 800),
            child: Text(
              'Welcome back.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 38.sp,
                fontWeight: FontWeight.w700,
                color: _ink900,
                letterSpacing: -1.2,
                height: 1.05,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          LoginEntranceWrap(
            duration: const Duration(milliseconds: 1000),
            child: Text(
              'Sign in to manage your petty cash workspace.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: _ink500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLockup() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Shield in a gradient circle, wrapped in a subtle accent ring.
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1.4,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/cashora_shield.png',
              width: 28.w,
              height: 28.w,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cashora',
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Smart petty cash',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _ink500,
                letterSpacing: 0.2,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
