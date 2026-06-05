import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/skeletons/page_skeletons.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/services/auth_service.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_admin_card.dart';
import 'widgets/profile_settings_card.dart';
import 'widgets/profile_section_label.dart';
import 'widgets/profile_logout_button.dart';
import 'widgets/profile_bottom_bar.dart';

class ProfileView extends GetView<ProfileController> {
  final bool isTab;
  const ProfileView({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      bottomNavigationBar: isTab ? null : const ProfileBottomBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ProfilePageSkeleton();
        }
        return CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: ProfileHeader(controller: controller, isTab: isTab),
            ),
            // ── Body ────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Info section
                  const ProfileSectionLabel('PERSONAL INFO'),
                  SizedBox(height: 10.h),
                  ProfileInfoCard(controller: controller),
                  SizedBox(height: 20.h),

                  // Admin actions
                  if (_isAdmin) ...[
                    const ProfileSectionLabel('ADMIN'),
                    SizedBox(height: 10.h),
                    ProfileAdminCard(controller: controller),
                    SizedBox(height: 20.h),
                  ],

                  // General actions
                  const ProfileSectionLabel('SETTINGS'),
                  SizedBox(height: 10.h),
                  ProfileSettingsCard(controller: controller),

                  SizedBox(height: 36.h),
                  ProfileLogoutButton(onTap: controller.logout),
                  SizedBox(height: 20.h),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  bool get _isAdmin => ['admin', 'super_admin']
      .contains(Get.find<AuthService>().currentUser.value?.role.toLowerCase());
}
