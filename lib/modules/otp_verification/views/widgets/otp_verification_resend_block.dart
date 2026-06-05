import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/otp_verification_controller.dart';

class OtpVerificationResendBlock extends StatelessWidget {
  const OtpVerificationResendBlock({super.key, required this.controller});

  final OtpVerificationController controller;

  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink300 = Color(0xFFCBD5E1);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
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
}
