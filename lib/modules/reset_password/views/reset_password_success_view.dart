import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';

class ResetPasswordSuccessView extends StatelessWidget {
  const ResetPasswordSuccessView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: _greenBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _green.withOpacity(0.2),
                      blurRadius: 30.r,
                      spreadRadius: 4.r,
                    ),
                  ],
                ),
                child: Icon(Icons.lock_reset_rounded,
                    color: _green, size: 58.sp),
              ),
              SizedBox(height: 32.h),
              Text(
                AppText.passwordUpdatedSuccess,
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: _slate900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'You can now sign in with your new password',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: _slate500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
                  icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
                  label: Text(
                    AppText.backToLogin,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
