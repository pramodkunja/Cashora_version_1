import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/otp_verification_controller.dart';

class OtpVerificationView extends GetView<OtpVerificationController> {
  const OtpVerificationView({super.key});

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
                          child: _buildOtpCard(),
                        ),
                        SizedBox(height: 20.h),
                        _entranceWrap(
                          duration: const Duration(milliseconds: 1000),
                          child: _buildResendBlock(),
                        ),
                        SizedBox(height: 28.h),
                        _entranceWrap(
                          duration: const Duration(milliseconds: 1100),
                          child: _buildGradientButton(
                            label: AppText.verify,
                            onTap: controller.verifyOtp,
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
            Icons.mark_email_read_rounded,
            color: Colors.white,
            size: 44.sp,
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
            'VERIFY EMAIL',
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
          'Check your inbox',
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
            AppText.otpSentTo(controller.email),
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

  Widget _buildOtpCard() {
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
                children: [
                  Text(
                    'Enter the 6-digit code',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _ink700,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, _buildOtpBox),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 44.w,
      height: 56.h,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          controller.focusNodes[index],
          controller.otpControllers[index],
        ]),
        builder: (context, _) {
          final bool focused = controller.focusNodes[index].hasFocus;
          final bool filled =
              controller.otpControllers[index].text.isNotEmpty;
          final Color borderColor = focused
              ? AppColors.primary
              : (filled ? AppColors.primary.withValues(alpha: 0.45) : _border);
          final double borderWidth = focused ? 1.8 : 1.2;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: filled ? AppColors.primary.withValues(alpha: 0.06) : _surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: focused
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 10.r,
                        offset: Offset(0, 2.h),
                      ),
                    ]
                  : const [],
            ),
            child: Center(
              child: TextField(
                controller: controller.otpControllers[index],
                focusNode: controller.focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: filled ? AppColors.primary : _ink900,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                cursorColor: AppColors.primary,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) =>
                    controller.onOtpDigitEntered(index, value),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResendBlock() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppText.didntReceiveCode,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: _ink500,
              ),
            ),
            SizedBox(width: 4.w),
            Obx(() {
              final canResend = controller.canResend.value;
              return GestureDetector(
                onTap: canResend ? controller.resendCode : null,
                child: Text(
                  AppText.resend,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: canResend ? AppColors.primary : _ink300,
                  ),
                ),
              );
            }),
          ],
        ),
        SizedBox(height: 10.h),
        Obx(() {
          // Compact timer chip — drawn only while resend is on cooldown.
          if (controller.canResend.value) return const SizedBox.shrink();
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14.sp, color: _ink500),
                SizedBox(width: 6.w),
                Text(
                  '${AppText.resendCodeIn} ${controller.formattedTime}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: _ink700,
                  ),
                ),
              ],
            ),
          );
        }),
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
}
