import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminRejectionSuccessView extends StatelessWidget {
  const AdminRejectionSuccessView({super.key});


  void _navigateBack() {
    Get.offNamedUntil(AppRoutes.ADMIN_DASHBOARD, (route) => false);
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        Get.find<AdminDashboardController>().changeTab(1);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _navigateBack,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8.r,
                          ),
                        ],
                      ),
                      child: Icon(Icons.close_rounded,
                          color: AppColors.textDark, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: AppColors.redBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.errorRed.withValues(alpha: 0.2),
                            blurRadius: 30.r,
                            spreadRadius: 4.r,
                          ),
                        ],
                      ),
                      child: Icon(Icons.thumb_down_alt_rounded,
                          color: AppColors.errorRed, size: 52.sp),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      AppText.requestRejected,
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppText.requestRejectedDesc,
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
                        onPressed: _navigateBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          AppText.backToApprovalsList,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
