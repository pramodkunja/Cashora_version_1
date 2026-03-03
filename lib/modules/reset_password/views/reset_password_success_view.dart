import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../routes/app_routes.dart';

class ResetPasswordSuccessView extends StatelessWidget {
  const ResetPasswordSuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: EdgeInsets.all(24.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80.sp,
              color: AppColors.successGreen,
            ),
            SizedBox(height: 24.h),
            Text(
              AppText.passwordUpdatedSuccess,
              style: AppTextStyles.h2.copyWith(fontSize: 24.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48.h),
            PrimaryButton(
              text: AppText.backToLogin,
              onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
            ),
          ],
        ),
      ),
    );
  }
}
