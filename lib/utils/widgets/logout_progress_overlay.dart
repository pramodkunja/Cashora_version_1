import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_colors.dart';

/// Full-screen blocking indicator shown while the user is being signed out.
///
/// Inserted directly into the navigator overlay by [AuthService.logout] so it
/// covers the screen during the (network-bound) logout calls and is removed
/// right before the app navigates back to the login screen.
class LogoutProgressOverlay extends StatelessWidget {
  const LogoutProgressOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 26.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 46.w,
                height: 46.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3.2,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Logging out…',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Please wait a moment',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textSlate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
