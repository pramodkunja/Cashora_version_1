import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/forgot_password_controller.dart';
import 'widgets/forgot_password_background.dart';
import 'widgets/forgot_password_hero.dart';
import 'widgets/forgot_password_form.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ForgotPasswordBackground(),
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
                          child: const ForgotPasswordHero(),
                        ),
                        SizedBox(height: 28.h),
                        _entranceWrap(
                          duration: const Duration(milliseconds: 800),
                          child: ForgotPasswordForm(controller: controller),
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
}
