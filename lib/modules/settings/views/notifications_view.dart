import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/settings_toggle_tile.dart';
import '../../profile/controllers/settings_controller.dart';

class NotificationsView extends GetView<SettingsController> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppText.notifications, style: AppTextStyles.h3),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              'Manage your push notification preferences for account activity.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTextStyles.bodyMedium.color,
              ),
            ),
            SizedBox(height: 24.h),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Column(
                children: [
                  Obx(
                    () => SettingsToggleTile(
                      icon: Icons.verified_user_rounded,
                      title: AppText.approvalStatusUpdates,
                      subtitle: AppText.approvalStatusDesc,
                      value: controller.rxNotifyApproval.value,
                      onChanged: (v) => controller.rxNotifyApproval.value = v,
                    ),
                  ),
                  Obx(
                    () => SettingsToggleTile(
                      icon: Icons.note_add_rounded,
                      title: AppText.newRequestSubmitted,
                      subtitle: AppText.newRequestDesc,
                      value: controller.rxNotifyRequest.value,
                      onChanged: (v) => controller.rxNotifyRequest.value = v,
                    ),
                  ),
                  Obx(
                    () => SettingsToggleTile(
                      icon: Icons.access_time_filled_rounded,
                      title: AppText.paymentReminders,
                      subtitle: AppText.paymentRemindersDesc,
                      value: controller.rxNotifyPayment.value,
                      onChanged: (v) => controller.rxNotifyPayment.value = v,
                    ),
                  ),
                  Obx(
                    () => SettingsToggleTile(
                      icon: Icons.help_center_rounded,
                      title: AppText.clarificationRequests,
                      subtitle: AppText.clarificationRequestsDesc,
                      value: controller.rxNotifyClarification.value,
                      onChanged: (v) =>
                          controller.rxNotifyClarification.value = v,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Email notifications can be managed separately in your\nAccount Settings.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTextStyles.bodyMedium.color,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
