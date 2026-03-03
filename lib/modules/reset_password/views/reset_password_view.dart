import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/app_loader.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Back Button
            Positioned(
              top: 16.h,
              left: 16.w,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 24.sp,
                ),
                onPressed: () => Get.back(),
              ),
            ),

            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lock Icon Badge
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.infoBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 40.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    Text(
                      'Reset Password',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: Text(
                        'Your new password must be different from previously used passwords.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                          height: 1.5,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // New Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildLabel('New Password'),
                    ),
                    SizedBox(height: 8.h),
                    Obx(
                      () => TextField(
                        controller: controller.newPasswordController,
                        obscureText: controller.isNewPasswordHidden.value,
                        decoration: _inputDecoration(
                          hint: 'Enter new password',
                          isObscure: controller.isNewPasswordHidden.value,
                          onToggleVisibility:
                              controller.toggleNewPasswordVisibility,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Confirm Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildLabel('Confirm Password'),
                    ),
                    SizedBox(height: 8.h),
                    Obx(
                      () => TextField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.isConfirmPasswordHidden.value,
                        decoration: _inputDecoration(
                          hint: 'Confirm new password',
                          isObscure: controller.isConfirmPasswordHidden.value,
                          onToggleVisibility:
                              controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // Update Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : controller.resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading
                              ? const AppSpinner(size: 30)
                              : Text(
                                  'Update Password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        fontSize: 14.sp,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF94A3B8),
        fontSize: 14.sp,
      ), // Slate 400
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        color: const Color(0xFF94A3B8),
        size: 24.sp,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xFF94A3B8),
          size: 24.sp,
        ),
        onPressed: onToggleVisibility,
        color: const Color(0xFF94A3B8),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
