import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../profile/controllers/settings_controller.dart';

class AppearanceView extends GetView<SettingsController> {
  const AppearanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Appearance',
          style: AppTextStyles.h3,
        ), // AppText.appearance
        backgroundColor: Theme.of(
          context,
        ).scaffoldBackgroundColor, // Match scaffold
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTextStyles.h3.color,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppText.appTheme,
              style: AppTextStyles.h3.copyWith(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.all(8.w),
              child: Column(
                children: [
                  Obx(
                    () => Column(
                      children: [
                        GestureDetector(
                          onTap: () => controller.selectTheme(0),
                          child: _buildThemeOption(
                            context,
                            Icons.light_mode,
                            AppText.lightTheme,
                            controller.rxPendingThemeMode.value == 0,
                            Colors.orange,
                          ),
                        ),
                        const Divider(),
                        GestureDetector(
                          onTap: () => controller.selectTheme(1),
                          child: _buildThemeOption(
                            context,
                            Icons.dark_mode,
                            AppText.darkTheme,
                            controller.rxPendingThemeMode.value == 1,
                            Colors.indigo,
                          ),
                        ),
                        const Divider(),
                        GestureDetector(
                          onTap: () => controller.selectTheme(2),
                          child: _buildThemeOption(
                            context,
                            Icons.settings,
                            AppText.systemDefault,
                            controller.rxPendingThemeMode.value == 2,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Removed Text Size and Preview as requested
            SizedBox(height: 40.h),
            PrimaryButton(
              text: AppText.saveChanges,
              onPressed: controller.saveThemeChanges,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    IconData icon,
    String label,
    bool selected,
    Color iconColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
            ),
          ),
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.primaryBlue
                    : Theme.of(context).dividerColor,
                width: 2.w,
              ),
              color: selected
                  ? Theme.of(context).cardColor
                  : Colors.transparent,
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
