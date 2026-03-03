import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as image_filter;

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/app_text.dart';
import '../controllers/admin_set_limits_controller.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';

class AdminSetLimitsView extends GetView<AdminSetLimitsController> {
  const AdminSetLimitsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(AppText.adminSetLimits, style: AppTextStyles.h3),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppText.limitConfigDesc,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSlate,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Deemed Limit
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: _buildLimitField(
                      context,
                      label: AppText.deemedLimitLabel,
                      controller: controller.deemedLimitController,
                      description: AppText.deemedLimitDesc,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => PrimaryButton(
                    text: controller.isSaving.value
                        ? AppText.saving
                        : AppText.saveLimits,
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.saveLimits,
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      AppText.cancel,
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.h3.copyWith(
            fontSize: 14.sp,
          ), // Smaller bold label
        ),
        SizedBox(height: 16.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.h3.copyWith(color: AppColors.textDark),
          decoration: InputDecoration(
            prefixIcon: Container(
              width: 40.w,
              alignment: Alignment.center,
              child: Text(
                '₹',
                style: AppTextStyles.h3.copyWith(color: AppColors.textSlate),
              ),
            ),
            suffixIcon: Container(
              width: 50.w,
              alignment: Alignment.center,
              child: Text(
                AppText.inrSuffix,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSlate,
                ),
              ),
            ),
            hintText: '0',
            hintStyle: AppTextStyles.h3.copyWith(color: AppColors.textLight),
            filled: true,
            fillColor: AppColors.backgroundAlt,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
        ),
      ],
    );
  }
}
