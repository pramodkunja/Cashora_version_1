import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../profile/controllers/settings_controller.dart';

class ChangePasswordView extends GetView<SettingsController> {
  const ChangePasswordView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _green = Color(0xFF16A34A);
  static const _greenBg = Color(0xFFF0FDF4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: _purple, size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Your new password must be different from previously used passwords.',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: _purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Current Password Card ──
                  _buildPasswordCard(
                    icon: Icons.lock_rounded,
                    title: AppText.currentPassword,
                    child: Obx(
                      () => _buildPasswordField(
                        hint: AppText.enterCurrentPassword,
                        fieldController:
                            controller.currentPasswordController,
                        isVisible:
                            controller.rxCurrentPasswordVisible.value,
                        onToggle:
                            controller.toggleCurrentPasswordVisibility,
                        hasError:
                            controller.rxCurrentPasswordError.value,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── New Password Card ──
                  _buildPasswordCard(
                    icon: Icons.vpn_key_rounded,
                    title: AppText.newPassword,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => _buildPasswordField(
                            hint: AppText.enterNewPassword,
                            fieldController:
                                controller.newPasswordController,
                            isVisible:
                                controller.rxNewPasswordVisible.value,
                            onToggle:
                                controller.toggleNewPasswordVisibility,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Obx(() => _buildCheck(
                              AppText.mustBeAtLeast8Chars,
                              controller.rxPasswordLength.value,
                            )),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Confirm Password Card ──
                  _buildPasswordCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: AppText.confirmNewPassword,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => _buildPasswordField(
                            hint: AppText.reEnterNewPassword,
                            fieldController:
                                controller.confirmPasswordController,
                            isVisible:
                                controller.rxConfirmPasswordVisible.value,
                            onToggle:
                                controller.toggleConfirmPasswordVisibility,
                            hasError:
                                controller.rxConfirmPasswordError.value,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Obx(() => _buildCheck(
                              AppText.bothPasswordsMatch,
                              controller.rxPasswordMatch.value,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Action Bar ──
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10.r,
                  offset: Offset(0, -4.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: controller.changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      AppText.updatePassword,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      AppText.forgotPasswordQuestion,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: _purple,
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

  // ════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 12.h,
        20.w,
        20.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Change Password',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // PASSWORD CARD — wraps each section in a white card with icon + title
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildPasswordCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: _purple, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _slate900,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // PASSWORD FIELD — inside the card
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildPasswordField({
    required String hint,
    required TextEditingController fieldController,
    required bool isVisible,
    required VoidCallback onToggle,
    bool hasError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasError ? AppColors.errorRed : const Color(0xFFE2E8F0),
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: fieldController,
        obscureText: !isVisible,
        style: GoogleFonts.inter(fontSize: 14.sp, color: _slate900),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: _slate300,
          ),
          prefixIcon: Icon(Icons.lock_outline_rounded,
              color: _slate500, size: 18.sp),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _slate500,
              size: 18.sp,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // VALIDATION CHECK
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildCheck(String text, bool passed) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: passed ? _greenBg : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 14.sp,
            color: passed ? _green : _slate500,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: passed ? _green : _slate500,
            ),
          ),
        ],
      ),
    );
  }
}
