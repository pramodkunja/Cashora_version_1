import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'widgets/admin_dashboard_action_tile.dart';
import 'widgets/admin_dashboard_header.dart';
import 'widgets/admin_dashboard_hero_stats.dart';
import 'widgets/admin_dashboard_org_card.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  // Local accent palette for the action tiles that don't already live in
  // AppColors (blue / pink).
  static const _blue = Color(0xFF0EA5E9);
  static const _blueBg = Color(0xFFE0F2FE);
  static const _pink = Color(0xFFEC4899);
  static const _pinkBg = Color(0xFFFCE7F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([
            controller.fetchDashboard(),
            controller.fetchApproverStats(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AdminDashboardHeader(controller: controller),
            ),

            // Hero stat card sits below the gradient with a small breathing
            // gap — clear of the welcome text, fully visible.
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0.h),
                child: AdminDashboardHeroStats(controller: controller),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 40.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _sectionLabel('ORGANIZATION'),
                  SizedBox(height: 12.h),
                  AdminDashboardOrgCard(controller: controller),

                  SizedBox(height: 26.h),
                  _sectionLabel('QUICK ACTIONS'),
                  SizedBox(height: 12.h),

                  AdminDashboardActionTile(
                    icon: Icons.hourglass_top_rounded,
                    iconColor: AppColors.warningOrange,
                    iconBg: AppColors.amberBg,
                    title: AppText.reviewPending,
                    subtitle: AppText.viewAllRequests,
                    onTap: controller.navigateToApprovals,
                  ),
                  SizedBox(height: 12.h),
                  AdminDashboardActionTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.purpleSurface,
                    title: 'In Clarification',
                    subtitle: 'Items waiting for requestor response',
                    onTap: controller.navigateToApprovals,
                    trailingBuilder: () => Obx(
                      () => AdminDashboardCountPill(
                        count: controller.inClarificationCount.value,
                        accent: AppColors.primary,
                        bg: AppColors.purpleSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AdminDashboardActionTile(
                    icon: Icons.history_rounded,
                    iconColor: _blue,
                    iconBg: _blueBg,
                    title: AppText.viewHistory,
                    subtitle: AppText.pastApprovals,
                    onTap: () => controller.changeTab(2),
                  ),
                  SizedBox(height: 12.h),
                  AdminDashboardActionTile(
                    icon: Icons.person_add_rounded,
                    iconColor: AppColors.successGreen,
                    iconBg: AppColors.mintBg,
                    title: AppText.addNewUser,
                    subtitle: AppText.createNewAccount,
                    onTap: () => Get.toNamed(AppRoutes.ADMIN_ADD_USER),
                  ),
                  SizedBox(height: 12.h),
                  AdminDashboardActionTile(
                    icon: Icons.business_rounded,
                    iconColor: _pink,
                    iconBg: _pinkBg,
                    title: 'Manage Departments',
                    subtitle: 'Create, edit & organize departments',
                    onTap: () => Get.toNamed(AppRoutes.ADMIN_DEPARTMENTS),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSlate,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
