import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminSuccessView extends StatelessWidget {
  const AdminSuccessView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
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
                  color: AppColors.mintBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.successGreen.withValues(alpha: 0.2),
                      blurRadius: 30.r,
                      spreadRadius: 4.r,
                    ),
                  ],
                ),
                child: Icon(Icons.check_rounded, color: AppColors.successGreen, size: 64.sp),
              ),
              SizedBox(height: 32.h),
              Text(
                AppText.approvedSuccessTitle,
                style: GoogleFonts.inter(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                AppText.approvedSuccessDesc,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSlate,
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
                    backgroundColor: AppColors.primary,
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
