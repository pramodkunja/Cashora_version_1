import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';

class AdminClarificationSuccessView extends StatelessWidget {
  const AdminClarificationSuccessView({super.key});


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
                    onTap: () => Get.offAllNamed(AppRoutes.ADMIN_APPROVALS),
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
                        color: AppColors.purpleSurface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 30.r,
                            spreadRadius: 4.r,
                          ),
                        ],
                      ),
                      child: Icon(Icons.mark_email_read_rounded,
                          color: AppColors.primary, size: 54.sp),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      AppText.sentBackSuccessfully,
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppText.sentBackDesc,
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
                        onPressed: () =>
                            Get.offAllNamed(AppRoutes.ADMIN_APPROVALS),
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
