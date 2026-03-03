import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../profile/controllers/settings_controller.dart';

class ChangePasswordView extends GetView<SettingsController> {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Change Password', style: AppTextStyles.h3),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your new password must be different from previous used passwords.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTextStyles.bodyMedium.color,
              ),
            ),
            SizedBox(height: 24.h),

            _buildLabel(AppText.currentPassword),
            Obx(
              () => _buildPasswordField(
                context,
                AppText.enterCurrentPassword,
                controller.currentPasswordController,
                isVisible: controller.rxCurrentPasswordVisible.value,
                onToggleVisibility: controller.toggleCurrentPasswordVisibility,
                showHighlightError: controller.rxCurrentPasswordError.value,
              ),
            ),
            SizedBox(height: 20.h),

            _buildLabel(AppText.newPassword),
            Obx(
              () => _buildPasswordField(
                context,
                AppText.enterNewPassword,
                controller.newPasswordController,
                isVisible: controller.rxNewPasswordVisible.value,
                onToggleVisibility: controller.toggleNewPasswordVisibility,
              ),
            ),
            SizedBox(height: 6.h),
            Obx(
              () => Row(
                children: [
                  Icon(
                    controller.rxPasswordLength.value
                        ? Icons.check_circle
                        : Icons.info,
                    size: 14.sp,
                    color: controller.rxPasswordLength.value
                        ? Colors.green
                        : AppColors.textSlate,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    AppText.mustBeAtLeast8Chars,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.sp,
                      color: controller.rxPasswordLength.value
                          ? Colors.green
                          : AppColors.textSlate,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
            _buildLabel(AppText.confirmNewPassword),
            Obx(
              () => _buildPasswordField(
                context,
                AppText.reEnterNewPassword,
                controller.confirmPasswordController,
                isVisible: controller.rxConfirmPasswordVisible.value,
                onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                showHighlightError: controller.rxConfirmPasswordError.value,
              ),
            ),
            SizedBox(height: 6.h),
            Obx(
              () => Row(
                children: [
                  Icon(
                    controller.rxPasswordMatch.value
                        ? Icons.check_circle
                        : Icons.info,
                    size: 14.sp,
                    color: controller.rxPasswordMatch.value
                        ? Colors.green
                        : AppColors.textSlate,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    AppText.bothPasswordsMatch,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.sp,
                      color: controller.rxPasswordMatch.value
                          ? Colors.green
                          : AppColors.textSlate,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 48.h),
            PrimaryButton(
              text: AppText.updatePassword,
              onPressed: controller.changePassword,
            ),
            SizedBox(height: 16.h),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  AppText.forgotPasswordQuestion,
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h, left: 4.w),
      child: Text(text, style: AppTextStyles.h3.copyWith(fontSize: 14.sp)),
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    String hint,
    TextEditingController fieldController, {
    required VoidCallback onToggleVisibility,
    required bool isVisible,
    bool showHighlightError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: showHighlightError
              ? Colors.red
              : AppColors.borderLight, // Highlight red on error
          width: showHighlightError ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        controller: fieldController,
        obscureText: !isVisible, // Use visibility state
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textLight,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 16.h,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textLight,
              size: 24.sp,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }
}
