import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_text.dart';
import '../controllers/otp_verification_controller.dart';
import 'widgets/otp_verification_background.dart';
import 'widgets/otp_verification_card.dart';
import 'widgets/otp_verification_gradient_button.dart';
import 'widgets/otp_verification_hero.dart';
import 'widgets/otp_verification_resend_block.dart';

class OtpVerificationView extends GetView<OtpVerificationController> {
  const OtpVerificationView({super.key});

  static const Color _ink700 = Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const OtpVerificationBackground(),
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
                          child: OtpVerificationHero(email: controller.email),
                        ),
                        SizedBox(height: 28.h),
                        _entranceWrap(
                          duration: const Duration(milliseconds: 800),
                          child: OtpVerificationCard(controller: controller),
                        ),
                        SizedBox(height: 20.h),
                        _entranceWrap(
                          duration: const Duration(milliseconds: 1000),
                          child: OtpVerificationResendBlock(
                              controller: controller),
                        ),
                        SizedBox(height: 28.h),
                        _entranceWrap(
                          duration: const Duration(milliseconds: 1100),
                          child: OtpVerificationGradientButton(
                            controller: controller,
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
