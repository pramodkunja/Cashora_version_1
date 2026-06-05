import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/auth_controller.dart';
import 'login_entrance_wrap.dart';
import 'login_sign_in_button.dart';

/// White bottom sheet that hosts the email / password fields, the
/// gradient sign-in button, the OR divider, and the setup-org button.
class LoginFormSection extends StatelessWidget {
  const LoginFormSection({
    super.key,
    required this.controller,
    required this.bottomInset,
  });

  final AuthController controller;
  final double bottomInset;

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink200 = Color(0xFFE2E8F0);
  static const Color _surface = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(42.r),
          topRight: Radius.circular(42.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 28.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        // Bottom padding includes the system inset so the last form element
        // doesn't collide with the home indicator / gesture bar.
        padding: EdgeInsets.fromLTRB(26.w, 14.h, 26.w, 26.h + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sheet handle — small ergonomic detail
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: _ink200,
                  borderRadius: BorderRadius.circular(2.h),
                ),
              ),
            ),
            SizedBox(height: 22.h),
            LoginEntranceWrap(
              duration: const Duration(milliseconds: 900),
              child: Text(
                'Sign in to continue',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: _ink900,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            LoginEntranceWrap(
              duration: const Duration(milliseconds: 1000),
              child: Text(
                'Use your work email to access the dashboard.',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: _ink500,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            LoginEntranceWrap(
              duration: const Duration(milliseconds: 1050),
              child: Obx(
                () => TextField(
                  controller: controller.emailController,
                  enabled: !controller.isLoading,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
                  cursorColor: AppColors.primary,
                  decoration: _floatingLabelDecoration(
                    label: 'Email address',
                    icon: Icons.mail_outline_rounded,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            LoginEntranceWrap(
              duration: const Duration(milliseconds: 1100),
              child: Obx(
                () => TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  enabled: !controller.isLoading,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => controller.login(),
                  style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
                  cursorColor: AppColors.primary,
                  decoration: _floatingLabelDecoration(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _ink500,
                        size: 20.sp,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),
            LoginEntranceWrap(
              duration: const Duration(milliseconds: 1150),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 4.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppText.forgotPassword,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            LoginEntranceWrap(
              duration: const Duration(milliseconds: 1200),
              child: LoginSignInButton(controller: controller),
            ),

            SizedBox(height: 22.h),

            LoginEntranceWrap(
              duration: const Duration(milliseconds: 1300),
              child: _buildOrDivider(),
            ),
            SizedBox(height: 18.h),

            LoginEntranceWrap(
              duration: const Duration(milliseconds: 1400),
              child: _buildSetupOrgButton(),
            ),
            SizedBox(height: 24.h),

            LoginEntranceWrap(
              duration: const Duration(milliseconds: 1500),
              child: Center(
                child: Text(
                  'Need help signing in? Contact your admin.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: _ink500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: _ink200)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: _ink500,
              letterSpacing: 1.6,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: _ink200)),
      ],
    );
  }

  Widget _buildSetupOrgButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        onPressed: () => Get.toNamed(AppRoutes.ORGANIZATION_SETUP),
        icon: Icon(Icons.domain_add_outlined, size: 20.sp, color: _ink700),
        label: Text(
          AppText.setUpOrganization,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: _ink700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _ink200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          backgroundColor: _surface,
        ),
      ),
    );
  }

  InputDecoration _floatingLabelDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: _ink500,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: 12.w, right: 8.w),
        child: Icon(icon, color: _ink500, size: 20.sp),
      ),
      prefixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
      suffixIcon: suffix,
      filled: true,
      fillColor: _surface,
      contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _ink200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _ink200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _ink200),
      ),
    );
  }
}
