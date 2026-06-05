import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../controllers/otp_verification_controller.dart';

class OtpVerificationCard extends StatelessWidget {
  const OtpVerificationCard({super.key, required this.controller});

  final OtpVerificationController controller;

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
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
}
