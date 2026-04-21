import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/date_helper.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        color: _purple,
        onRefresh: controller.fetchDashboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildOverviewCards(),
                  SizedBox(height: 28.h),
                  _buildSectionTitle(AppText.actions),
                  SizedBox(height: 14.h),
                  _buildActionTile(
                    icon: Icons.hourglass_top_rounded,
                    title: AppText.reviewPending,
                    subtitle: AppText.viewAllRequests,
                    onTap: controller.navigateToApprovals,
                  ),
                  SizedBox(height: 10.h),
                  _buildActionTile(
                    icon: Icons.history_rounded,
                    title: AppText.viewHistory,
                    subtitle: AppText.pastApprovals,
                    onTap: () => controller.changeTab(2),
                  ),
                  SizedBox(height: 10.h),
                  _buildActionTile(
                    icon: Icons.person_add_rounded,
                    title: AppText.addNewUser,
                    subtitle: AppText.createNewAccount,
                    onTap: () => Get.toNamed(AppRoutes.ADMIN_ADD_USER),
                  ),
                  SizedBox(height: 10.h),
                  _buildActionTile(
                    icon: Icons.business_rounded,
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

  // ── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        MediaQuery.of(context).padding.top + 16.h,
        24.w,
        28.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_greeting()}',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(
                  () => Text(
                    controller.shortName,
                    style: GoogleFonts.inter(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  DateHelper.getFormattedDate(),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.ADMIN_NOTIFICATIONS),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Overview Cards ───────────────────────────────────────────────────
  Widget _buildOverviewCards() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _overviewCard(
              label: AppText.pending,
              value: controller.pendingRequestsCount.value.toString(),
              icon: Icons.pending_actions_rounded,
              accent: _purple,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: _overviewCard(
              label: AppText.approved,
              value:
                  '₹${controller.approvedAmount.value.toStringAsFixed(0)}',
              icon: Icons.check_circle_outline_rounded,
              accent: _green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accent, size: 20.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: _slate500,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: _slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: _slate900,
      ),
    );
  }

  // ── Action Tile ──────────────────────────────────────────────────────
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _purpleLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: _purple, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _slate900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: _slate500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _slate300,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}
