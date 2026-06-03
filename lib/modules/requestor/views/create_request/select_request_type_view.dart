import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/create_request_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/widgets/app_gradient_header.dart';
import '../../../../utils/app_text.dart';

class SelectRequestTypeView extends GetView<CreateRequestController> {
  const SelectRequestTypeView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          AppGradientHeader(title: AppText.selectRequestType),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT REQUEST TYPE',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSlate,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'How would you like to proceed?',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Obx(
                    () => _buildOptionCard(
                      title: AppText.preApproved,
                      subtitle: AppText.preApprovedDesc,
                      value: AppText.preApproved,
                      groupValue: controller.requestType.value,
                      icon: Icons.schedule_rounded,
                      onChanged: (v) => controller.requestType.value = v!,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => _buildOptionCard(
                      title: AppText.postApproved,
                      subtitle: AppText.postApprovedDesc,
                      value: AppText.postApproved,
                      groupValue: controller.requestType.value,
                      icon: Icons.receipt_long_rounded,
                      onChanged: (v) => controller.requestType.value = v!,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purpleSurface.withValues(alpha: 0.5) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.purpleSurface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textSlate,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                  width: 2.w,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.CREATE_REQUEST_DETAILS),
            icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
            label: Text(
              'Continue',
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
      ),
    );
  }
}
