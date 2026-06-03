import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../../profile/controllers/settings_controller.dart';

class ChangePasswordView extends GetView<SettingsController> {
  const ChangePasswordView({super.key});


  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: CashoraColors.bgB,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                AppTopBar(title: 'Change Password', onBack: () => Get.back()),
                Expanded(
                  child: WhiteSheet(
                    bottomInset: bottomInset,
                    padding:
                        const EdgeInsets.fromLTRB(24, 14, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EntranceWrap(
                          duration: const Duration(milliseconds: 600),
                          child: const HeroBadge(
                            icon: Icons.lock_reset_rounded,
                            diameter: 84,
                            iconSize: 38,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 700),
                          child: const HeroHeadline(
                            eyebrow: 'SECURE ACCESS',
                            headline: 'Change your password',
                            subtitle:
                                'Pick a strong password you haven\'t used before.',
                          ),
                        ),
                        SizedBox(height: 24.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 850),
                          child: Obx(
                            () => TextField(
                              controller:
                                  controller.currentPasswordController,
                              obscureText:
                                  !controller.rxCurrentPasswordVisible.value,
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: CashoraColors.ink900),
                              cursorColor: AppColors.primary,
                              decoration: cashoraInputDecoration(
                                label: AppText.currentPassword,
                                icon: Icons.lock_rounded,
                                suffix: _eyeButton(
                                  isVisible: controller
                                      .rxCurrentPasswordVisible.value,
                                  onTap: controller
                                      .toggleCurrentPasswordVisibility,
                                ),
                              ).copyWith(
                                errorText:
                                    controller.rxCurrentPasswordError.value
                                        ? 'Incorrect current password'
                                        : null,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 950),
                          child: Obx(
                            () => TextField(
                              controller: controller.newPasswordController,
                              obscureText:
                                  !controller.rxNewPasswordVisible.value,
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: CashoraColors.ink900),
                              cursorColor: AppColors.primary,
                              decoration: cashoraInputDecoration(
                                label: AppText.newPassword,
                                icon: Icons.vpn_key_rounded,
                                suffix: _eyeButton(
                                  isVisible:
                                      controller.rxNewPasswordVisible.value,
                                  onTap:
                                      controller.toggleNewPasswordVisibility,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 1050),
                          child: Obx(
                            () => TextField(
                              controller:
                                  controller.confirmPasswordController,
                              obscureText: !controller
                                  .rxConfirmPasswordVisible.value,
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: CashoraColors.ink900),
                              cursorColor: AppColors.primary,
                              decoration: cashoraInputDecoration(
                                label: AppText.confirmNewPassword,
                                icon: Icons.check_circle_outline_rounded,
                                suffix: _eyeButton(
                                  isVisible: controller
                                      .rxConfirmPasswordVisible.value,
                                  onTap: controller
                                      .toggleConfirmPasswordVisibility,
                                ),
                              ).copyWith(
                                errorText:
                                    controller.rxConfirmPasswordError.value
                                        ? 'Passwords don\'t match'
                                        : null,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 1150),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Obx(() => _checkPill(
                                        AppText.mustBeAtLeast8Chars,
                                        controller.rxPasswordLength.value,
                                      ))),
                              SizedBox(width: 10.w),
                              Expanded(
                                  child: Obx(() => _checkPill(
                                        AppText.bothPasswordsMatch,
                                        controller.rxPasswordMatch.value,
                                      ))),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 1250),
                          child: GradientButton(
                            label: AppText.updatePassword,
                            onTap: controller.changePassword,
                            leadingIcon: Icons.check_rounded,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 1350),
                          child: Center(
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                AppText.forgotPasswordQuestion,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
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
        ],
      ),
    );
  }

  Widget _eyeButton(
      {required bool isVisible, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(
        isVisible
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        color: CashoraColors.ink500,
        size: 20.sp,
      ),
      onPressed: onTap,
    );
  }

  Widget _checkPill(String text, bool passed) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: passed ? AppColors.mintBg : CashoraColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: passed ? AppColors.successGreen.withValues(alpha: 0.30) : CashoraColors.ink200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 14.sp,
            color: passed ? AppColors.successGreen : CashoraColors.ink500,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: passed ? AppColors.successGreen : CashoraColors.ink500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
