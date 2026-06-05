import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../controllers/reset_password_controller.dart';

class ResetPasswordForm extends StatelessWidget {
  const ResetPasswordForm({super.key, required this.controller});

  final ResetPasswordController controller;

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink300 = Color(0xFFCBD5E1);
  static const Color _surface = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.r),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 32.r,
              offset: Offset(0, 12.h),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 22.w, vertical: 26.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel(
                    icon: Icons.lock_outline_rounded,
                    label: 'New Password',
                  ),
                  SizedBox(height: 10.h),
                  Obx(
                    () => TextField(
                      controller: controller.newPasswordController,
                      obscureText: controller.isNewPasswordHidden.value,
                      enabled: !controller.isLoading,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: _ink900,
                      ),
                      decoration: _passwordDecoration(
                        hint: 'Enter new password',
                        isObscure: controller.isNewPasswordHidden.value,
                        onToggle: controller.toggleNewPasswordVisibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildFieldLabel(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Confirm Password',
                  ),
                  SizedBox(height: 10.h),
                  Obx(
                    () => TextField(
                      controller: controller.confirmPasswordController,
                      obscureText:
                          controller.isConfirmPasswordHidden.value,
                      enabled: !controller.isLoading,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.resetPassword(),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: _ink900,
                      ),
                      decoration: _passwordDecoration(
                        hint: 'Confirm new password',
                        isObscure: controller.isConfirmPasswordHidden.value,
                        onToggle:
                            controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: _ink900,
          ),
        ),
      ],
    );
  }

  InputDecoration _passwordDecoration({
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: _ink300),
      prefixIcon: Icon(Icons.lock_outline_rounded,
          color: _ink500, size: 20.sp),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: _ink500,
          size: 20.sp,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: _surface,
      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.6),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _border),
      ),
    );
  }
}
