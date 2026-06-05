import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/profile_controller.dart';
import 'profile_action_row.dart';
import 'profile_card.dart';

class ProfileAdminCard extends StatelessWidget {
  final ProfileController controller;

  const ProfileAdminCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(children: [
      ProfileActionRow(
        icon: Icons.people_outline_rounded,
        title: AppText.manageUsers,
        onTap: controller.navigateToManageUsers,
        accent: AppColors.successGreen,
        accentBg: AppColors.mintBg,
      ),
      ProfileActionRow(
        icon: Icons.business_rounded,
        title: 'Manage Departments',
        onTap: () => Get.toNamed(AppRoutes.ADMIN_DEPARTMENTS),
      ),
      ProfileActionRow(
        icon: Icons.category_rounded,
        title: 'Manage Categories',
        onTap: () => Get.toNamed(AppRoutes.ADMIN_CATEGORIES),
      ),
      ProfileActionRow(
        icon: Icons.tune_rounded,
        title: 'Set Approval Limits',
        onTap: () => Get.toNamed(AppRoutes.ADMIN_SET_LIMITS),
      ),
    ]);
  }
}
