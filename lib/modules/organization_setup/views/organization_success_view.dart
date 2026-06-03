import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';

class OrganizationSuccessView extends StatelessWidget {
  const OrganizationSuccessView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),
                  Center(
                    child: Container(
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
                      child: Icon(Icons.check_rounded,
                          color: AppColors.successGreen, size: 64.sp),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    AppText.organizationCreatedSuccess,
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    AppText.secureWorkspaceReady,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSlate,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),

                  // Email Info Card
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12.r,
                          offset: Offset(0, 3.h),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppColors.purpleSurface,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.mail_outline_rounded,
                              color: AppColors.primary, size: 20.sp),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppText.checkInbox,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                AppText.checkInboxDesc,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.textSlate,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
                      icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
                      label: Text(
                        AppText.goToLogin,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Wrap(
                      spacing: 4.w,
                      children: [
                        Text(
                          AppText.didntReceiveEmail,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.textSlate,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            AppText.contactSupport,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
