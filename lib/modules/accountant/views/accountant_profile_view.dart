import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../controllers/accountant_profile_controller.dart';
import 'widgets/accountant_bottom_bar.dart';

class AccountantProfileView extends GetView<AccountantProfileController> {
  const AccountantProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Bottom Nav handles navigation
        centerTitle: true,
        title: Text(
          AppText.myProfile,
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: controller.editProfile,
            child: Text(
              AppText.edit,
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Obx(
          () => Column(
            children: [
              // Profile Image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.lightBlue.shade100,
                    width: 4,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orangeAccent,
                  // backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=sarah'), // Mock
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.rxName.value,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.rxEmail.value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSlate,
                ),
              ),

              const SizedBox(height: 32),

              // Info Card
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.person,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: AppColors.primaryBlue,
                      label: AppText.fullName,
                      value: controller.rxName.value,
                    ),
                    const Divider(height: 24),
                    _buildInfoTile(
                      icon: Icons.email,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: AppColors.primaryBlue,
                      label: AppText.emailAddress,
                      value: controller.rxEmail.value,
                    ),
                    const Divider(height: 24),
                    _buildInfoTile(
                      icon: Icons.phone,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: AppColors.primaryBlue,
                      label: AppText.phone,
                      value: controller.rxPhone.value,
                    ),
                    const Divider(height: 24),
                    _buildInfoTile(
                      icon: Icons.badge,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: AppColors.primaryBlue,
                      label: AppText.role,
                      value: controller.rxRole.value,
                      showArrow: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions Card
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.lock,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: AppColors.primaryBlue,
                      title: AppText.changePassword,
                      onTap: controller.navigateToChangePassword,
                    ),
                    const Divider(height: 24),
                    _buildActionTile(
                      icon: Icons.settings,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: AppColors.primaryBlue,
                      title: AppText.appSettings,
                      onTap: controller.navigateToSettings,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              TextButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  AppText.logOut,
                  style: AppTextStyles.buttonText.copyWith(color: Colors.red),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg.withOpacity(Get.isDarkMode ? 0.2 : 1.0),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        if (showArrow)
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg.withOpacity(Get.isDarkMode ? 0.2 : 1.0),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTextStyles.bodySmall.color,
          ),
        ],
      ),
    );
  }
}
