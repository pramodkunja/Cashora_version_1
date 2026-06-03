import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

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
                          child: _buildFooterLink(),
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
          _circleIconButton(Icons.arrow_back_rounded, () => Get.back()),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(icon, color: _ink700, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        // Hero badge with gradient + halo glow
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
            Icons.lock_reset_rounded,
            color: Colors.white,
            size: 44.sp,
          ),
        ),
        SizedBox(height: 18.h),
        // Eyebrow pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'RECOVER ACCESS',
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
          'Forgot your password?',
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
            "Enter your registered email and we'll send a 6-digit verification code.",
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
                  Text(
                    'Email or Phone',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _ink700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Obx(
                    () => TextField(
                      controller: controller.emailController,
                      enabled: !controller.isLoading,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (_) => controller.sendCode(),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: _ink900,
                      ),
                      decoration: _inputDecoration(
                        hint: 'you@company.com',
                        icon: Icons.alternate_email_rounded,
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  _buildGradientButton(
                    label: 'Send Verification Code',
                    onTap: controller.sendCode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildFooterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: _ink500,
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Text(
            'Sign in',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: _ink300),
      prefixIcon: Icon(icon, color: _ink500, size: 20.sp),
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
