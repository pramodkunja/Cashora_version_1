import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  static const Color _bgTop = Color(0xFFF8F7FF);
  static const Color _bgBottom = Color(0xFFEEF2FF);
  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink300 = Color(0xFFCBD5E1);
  static const Color _surface = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _backgroundLayer(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),
                        _entranceWrap(
                          duration: const Duration(milliseconds: 600),
                          child: _buildHero(),
                        ),
                        SizedBox(height: 28.h),
                        _entranceWrap(
                          duration: const Duration(milliseconds: 800),
                          child: _buildFormCard(),
                        ),
                        SizedBox(height: 28.h),
                        _entranceWrap(
                          duration: const Duration(milliseconds: 1100),
                          child: _buildGradientButton(
                            label: 'Update Password',
                            onTap: controller.resetPassword,
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

  Widget _backgroundLayer() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgTop, _bgBottom],
            ),
          ),
        ),
        Positioned(
          top: -80.h,
          right: -60.w,
          child: _blob(260.w, AppColors.primary, 0.18),
        ),
        Positioned(
          bottom: -100.h,
          left: -80.w,
          child: _blob(300.w, AppColors.primaryLight, 0.22),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Get.back(),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Icon(Icons.arrow_back_rounded,
                    color: _ink700, size: 20.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 96.w,
          height: 96.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 24.r,
                offset: Offset(0, 12.h),
              ),
            ],
          ),
          child: Icon(
            Icons.vpn_key_rounded,
            color: Colors.white,
            size: 42.sp,
          ),
        ),
        SizedBox(height: 18.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'NEW PASSWORD',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.4,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Create a new password',
          style: GoogleFonts.inter(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: _ink900,
            height: 1.15,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            'Choose a strong password you haven’t used before.',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: _ink500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
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

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final bool busy = controller.isLoading;
      return Container(
        height: 54.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: busy
                ? [
                    AppColors.primary.withValues(alpha: 0.55),
                    AppColors.primaryLight.withValues(alpha: 0.55),
                  ]
                : [AppColors.primary, AppColors.primaryLight],
          ),
          boxShadow: busy
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 18.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: busy ? null : onTap,
            borderRadius: BorderRadius.circular(14.r),
            child: Center(
              child: busy
                  ? SizedBox(
                      height: 22.h,
                      width: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _entranceWrap({required Widget child, required Duration duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, t, c) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
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
