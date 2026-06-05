import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/app_colors.dart';

class AdminAddUserHero extends StatelessWidget {
  const AdminAddUserHero({super.key});

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 14.h, 28.w, 22.h),
      child: Column(
        children: [
          _entranceWrap(
            duration: const Duration(milliseconds: 600),
            child: _buildAvatarBadge(),
          ),
          SizedBox(height: 16.h),
          _entranceWrap(
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'NEW USER',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          _entranceWrap(
            duration: const Duration(milliseconds: 900),
            child: Text(
              'Add a team member',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: _ink900,
                letterSpacing: -0.6,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          _entranceWrap(
            duration: const Duration(milliseconds: 1000),
            child: Text(
              'Set up access for a new requestor or accountant.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
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

  Widget _buildAvatarBadge() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.20),
          width: 1.4,
        ),
      ),
      child: Container(
        width: 76.w,
        height: 76.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Icon(
          Icons.person_add_alt_1_rounded,
          color: Colors.white,
          size: 36.sp,
        ),
      ),
    );
  }

  Widget _entranceWrap({required Widget child, required Duration duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, t, c) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: c),
        );
      },
      child: child,
    );
  }
}
