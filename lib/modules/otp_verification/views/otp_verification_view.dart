import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/app_loader.dart';
import '../controllers/otp_verification_controller.dart';

class OtpVerificationView extends GetView<OtpVerificationController> {
  const OtpVerificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTextStyles.h3.color,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Badge
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_open_rounded, // or security
                  size: 40.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 32.h),

              // Headings
              Text(
                AppText.otpVerification, // "OTP Verification"
                style: AppTextStyles.h2.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              Text(
                AppText.otpSentTo(controller.email), // Dynamic message
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSlate,
                  height: 1.5,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 48.h),

              // OTP Inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => _buildOtpInput(context, index),
                ),
              ),
              SizedBox(height: 40.h),

              // Resend Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppText.didntReceiveCode,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSlate,
                      fontSize: 14.sp,
                    ),
                  ),
                  Obx(() {
                    if (controller.canResend.value) {
                      return GestureDetector(
                        onTap: controller.resendCode,
                        child: Text(
                          AppText.resend,
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      );
                    } else {
                      return Text(
                        AppText.resend,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      );
                    }
                  }),
                ],
              ),
              SizedBox(height: 8.h),
              Obx(
                () => Text(
                  '${AppText.resendCodeIn} ${controller.formattedTime}',
                  style: GoogleFonts.inter(
                    color: AppTextStyles.bodyMedium.color,
                    fontSize: 14.sp,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Verify Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : controller.verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading
                        ? const AppSpinner(size: 30)
                        : Text(
                            AppText.verify,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput(BuildContext context, int index) {
    return Container(
      width: 48.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.1),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: controller.otpControllers[index],
          focusNode: controller.focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppTextStyles.h3.color,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => controller.onOtpDigitEntered(index, value),
        ),
      ),
    );
  }
}
