import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminSuccessView extends StatelessWidget {
  const AdminSuccessView({Key? key}) : super(key: key);

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
                child: Icon(Icons.check_rounded, color: _green, size: 64.sp),
              ),
              SizedBox(height: 32.h),
              Text(
                AppText.approvedSuccessTitle,
                style: GoogleFonts.inter(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: _slate900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                AppText.approvedSuccessDesc,
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
                child: ElevatedButton(
                  onPressed: () {
                    Get.offNamedUntil(
                        AppRoutes.ADMIN_DASHBOARD, (route) => false);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      try {
                        Get.find<AdminDashboardController>().changeTab(1);
                      } catch (_) {}
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    AppText.backToApprovals,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
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
