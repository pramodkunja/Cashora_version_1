import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../controllers/department_controller.dart';

/// Empty placeholder shown when no departments exist yet.
class DepartmentEmptyState extends StatelessWidget {
  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);

  const DepartmentEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.10),
              ),
              child: Icon(
                Icons.apartment_rounded,
                color: AppColors.primary,
                size: 44.sp,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'No departments yet',
              style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: _ink900,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Use the menu to seed defaults\nor tap + to create one',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: _ink500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state with the controller's error message + a Retry button.
class DepartmentErrorState extends StatelessWidget {
  final DepartmentController controller;

  static const Color _ink700 = Color(0xFF334155);

  const DepartmentErrorState({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.errorRed.withOpacity(0.10),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 38.sp,
                color: AppColors.errorRed,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => Text(
                controller.errorMessage.value,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: _ink700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 18.h),
            Material(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: controller.fetchDepartments,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Add Department" floating action button — gradient pill with icon
/// and label. Triggers the controller's create-dialog.
class DepartmentGradientFab extends StatelessWidget {
  final DepartmentController controller;

  const DepartmentGradientFab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.40),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.showCreateDialog,
          borderRadius: BorderRadius.circular(26.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'Add Department',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
