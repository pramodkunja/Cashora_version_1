import 'package:flutter/material.dart';
import 'dart:ui' as image_filter; // Added for BackdropFilter
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../controllers/profile_controller.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../routes/app_routes.dart';
import '../../admin/views/widgets/admin_bottom_bar.dart';
import '../../requestor/views/widgets/requestor_bottom_bar.dart';
import '../../../../utils/widgets/app_loader.dart';
import '../../../../core/services/auth_service.dart';
// Needs custom layout for list items as per image (Icon box left, Text, Arrow)

class ProfileView extends GetView<ProfileController> {
  final bool isTab;
  const ProfileView({Key? key, this.isTab = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLight, // Removed to use Theme default
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isTab
            ? null
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textDark,
                  size: 24.sp,
                ),
                onPressed: () => Get.offNamed(AppRoutes.ADMIN_DASHBOARD),
              ),
        automaticallyImplyLeading: !isTab,
        centerTitle: true,
        title: Text(AppText.myProfile, style: AppTextStyles.h3),
        actions: [
          TextButton(
            onPressed: controller.editProfile,
            child: Text(
              AppText.edit,
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primary,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isTab ? null : _buildBottomBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: AppSpinner());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              // Profile Image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.lightBlue.shade100,
                    width: 4.w,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.person, size: 50.sp, color: Colors.white),
                ),
              ),
              SizedBox(height: 16.h),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Prevent taking full width
                  children: [
                    Flexible(
                      // allow text to shrink
                      child: Text(
                        controller.rxName.value,
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        controller.rxRole.value.toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Obx(
                () => Text(
                  controller.rxEmail.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSlate,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Info Card
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.all(20.w),
                child: Obx(
                  () => Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.business,
                        iconBg: AppColors.infoBg,
                        iconColor: AppColors.primary,
                        label: 'Organization Name',
                        value: controller.rxOrgName.value,
                      ),
                      Divider(height: 24.h),
                      _buildInfoTile(
                        icon: Icons.qr_code,
                        iconBg: AppColors.infoBg,
                        iconColor: AppColors.primary,
                        label: 'Organization Code',
                        value: controller.rxOrgCode.value,
                      ),
                      Divider(height: 24.h),
                      _buildInfoTile(
                        icon: Icons.phone,
                        iconBg: AppColors.infoBg,
                        iconColor: AppColors.primary,
                        label: AppText.phone,
                        value: controller.rxPhone.value,
                      ),
                      Divider(height: 24.h),
                      _buildInfoTile(
                        icon: Icons.badge,
                        iconBg: AppColors.infoBg,
                        iconColor: AppColors.primary,
                        label: AppText.role,
                        value: controller.rxRole.value,
                        showArrow: false,
                      ),
                    ],
                  ),
                ),
              ),



              if (['admin', 'super_admin'].contains(
                Get.find<AuthService>().currentUser.value?.role.toLowerCase(),
              )) ...[
                SizedBox(height: 24.h),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      _buildActionTile(
                        icon: Icons.people_outline_rounded,
                        iconBg: const Color(0xFFF0FDF4), // Light Green
                        iconColor: const Color(0xFF16A34A), // Green
                        title: AppText.manageUsers,
                        onTap: controller.navigateToManageUsers,
                      ),
                      Divider(height: 24.h),
                      _buildActionTile(
                        icon: Icons.tune_rounded,
                        iconBg: AppColors.surfacePurple,
                        iconColor: AppColors.primary,
                        title: 'Set Approval Limits',
                        onTap: () => Get.toNamed(AppRoutes.ADMIN_SET_LIMITS),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 24.h),

              // Actions Card
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.lock,
                      iconBg: AppColors.infoBg,
                      iconColor: AppColors.primary,
                      title: AppText.changePassword,
                      onTap: controller.navigateToChangePassword,
                    ),
                    Divider(height: 24.h),
                    _buildActionTile(
                      icon: Icons.settings,
                      iconBg: AppColors.infoBg,
                      iconColor: AppColors.primary,
                      title: AppText.appSettings,
                      onTap: controller.navigateToSettings,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),
              TextButton.icon(
                onPressed: controller.logout,
                icon: Icon(Icons.logout, color: Colors.red, size: 24.sp),
                label: Text(
                  AppText.logOut,
                  style: AppTextStyles.buttonText.copyWith(
                    color: Colors.red,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    bool showArrow = true,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: iconBg.withOpacity(
              Get.isDarkMode ? 0.2 : 1.0,
            ), // Adjust for dark mode visibility
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTextStyles.bodySmall.color,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(value, style: AppTextStyles.h3.copyWith(fontSize: 16.sp)),
            ],
          ),
        ),
        if (showArrow)
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16.sp,
            color: AppTextStyles.bodySmall.color,
          ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconBg.withOpacity(Get.isDarkMode ? 0.2 : 1.0),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16.sp,
            color: AppTextStyles.bodySmall.color,
          ),
        ],
      ),
    );
  }


  Widget _buildBottomBar() {
    final userRole = Get.find<AuthService>().currentUser.value?.role
        .toLowerCase();

    // Explicitly check for Admin/Approver
    if (userRole == 'admin' || userRole == 'super_admin') {
      return AdminBottomBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Get.offNamed(AppRoutes.ADMIN_DASHBOARD);
          if (index == 1) Get.offNamed(AppRoutes.ADMIN_APPROVALS);
          if (index == 2) Get.offNamed(AppRoutes.ADMIN_HISTORY);
          if (index == 3) {
            /* Current Page */
          }
        },
      );
    } else {
      // Default to Requestor for any other role (including 'requestor', 'user', null)
      return RequestorBottomBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Get.offNamed(AppRoutes.REQUESTOR);
          if (index == 1) Get.offNamed(AppRoutes.MY_REQUESTS);
          if (index == 2) {
            /* Current Page */
          }
        },
      );
    }
  }
}
