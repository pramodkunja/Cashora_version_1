import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../controllers/settings_controller.dart';
import '../../../../utils/widgets/custom_list_tile.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTextStyles.h3.color,
            size: 24.sp,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(AppText.settings, style: AppTextStyles.h3), // 'Settings'
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          children: [
            // Settings Group 1
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  CustomListTile(
                    title: AppText.notifications,
                    leadingIconWidget: Icon(
                      Icons.notifications,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                    onTap: controller.navigateToNotifications,
                  ),
                  CustomListTile(
                    title: AppText.currency,
                    leadingIconWidget: Icon(
                      Icons.currency_pound,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                    onTap: () {},
                  ),
                  CustomListTile(
                    title: AppText.appearance,
                    leadingIconWidget: Icon(
                      Icons.contrast,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                    onTap: controller.navigateToAppearance,
                    showDivider: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Settings Group 2 (Face ID & Password)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  // Face ID Toggle
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.fingerprint,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                    title: Text(
                      AppText.faceIdTouchId,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTextStyles.h3.color,
                      ),
                    ),
                    trailing: Obx(
                      () => Switch(
                        value: controller.rxFaceIdEnabled.value,
                        onChanged: controller.toggleFaceId,
                        activeColor: AppColors.primaryBlue,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  Divider(height: 1.h),
                  CustomListTile(
                    title: AppText.changePassword,
                    leadingIconWidget: Icon(
                      Icons.lock,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                    onTap: controller.navigateToChangePassword,
                    showDivider: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Settings Group 3
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  CustomListTile(
                    title: AppText.helpSupport,
                    leadingIconWidget: Icon(
                      Icons.help,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                    onTap: () {},
                  ),
                  CustomListTile(
                    title: AppText.privacyPolicy,
                    leadingIconWidget: Icon(
                      Icons.security,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                    onTap: () {},
                  ),
                  CustomListTile(
                    title: AppText.termsOfService,
                    leadingIconWidget: Icon(
                      Icons.description,
                      color: AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),

            // Logout Button (Full width blue light)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: controller.logout,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFD1F2FA,
                  ), // Light blue from image
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  AppText.logOut,
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
