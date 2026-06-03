import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import 'package:cash/utils/formatters/greeting_formatter.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/date_helper.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/admin_approvals_controller.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  // Palette
  static const _slate600 = Color(0xFF475569);
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
            SliverToBoxAdapter(child: _buildHeader(context)),

            // Hero stat card sits below the gradient with a small breathing
            // gap — clear of the welcome text, fully visible.
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0.h),
                child: _buildHeroStats(),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 40.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _sectionLabel('ORGANIZATION'),
                  SizedBox(height: 12.h),
                  _buildOrgSummaryCard(),

                  SizedBox(height: 26.h),
                  _sectionLabel('QUICK ACTIONS'),
                  SizedBox(height: 12.h),

                  _buildActionTile(
                    icon: Icons.hourglass_top_rounded,
                    iconColor: AppColors.warningOrange,
                    iconBg: AppColors.amberBg,
                    title: AppText.reviewPending,
                    subtitle: AppText.viewAllRequests,
                    onTap: controller.navigateToApprovals,
                  ),
                  SizedBox(height: 12.h),
                  _buildActionTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.purpleSurface,
                    title: 'In Clarification',
                    subtitle: 'Items waiting for requestor response',
                    onTap: controller.navigateToApprovals,
                    trailingBuilder: () => Obx(
                      () => _countPill(
                        controller.inClarificationCount.value,
                        accent: AppColors.primary,
                        bg: AppColors.purpleSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildActionTile(
                    icon: Icons.history_rounded,
                    iconColor: _blue,
                    iconBg: _blueBg,
                    title: AppText.viewHistory,
                    subtitle: AppText.pastApprovals,
                    onTap: () => controller.changeTab(2),
                  ),
                  SizedBox(height: 12.h),
                  _buildActionTile(
                    icon: Icons.person_add_rounded,
                    iconColor: AppColors.successGreen,
                    iconBg: AppColors.mintBg,
                    title: AppText.addNewUser,
                    subtitle: AppText.createNewAccount,
                    onTap: () => Get.toNamed(AppRoutes.ADMIN_ADD_USER),
                  ),
                  SizedBox(height: 12.h),
                  _buildActionTile(
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

  // ════════════════════════════════════════════════════════════════════════
  // Header banner — greeting + bell. Tall enough so the hero stat card has
  // room to overlap it.
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24.w,
        MediaQuery.of(context).padding.top + 18.h,
        24.w,
        26.h,
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
                  'Good ${GreetingFormatter.timeOfDay()}',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(
                  () => Text(
                    controller.shortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11.sp,
                        color: Colors.white.withValues(alpha: 0.75)),
                    SizedBox(width: 6.w),
                    Text(
                      DateHelper.getFormattedDate(),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.ADMIN_NOTIFICATIONS),
            child: Container(
              padding: EdgeInsets.all(11.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
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

  // ════════════════════════════════════════════════════════════════════════
  // Hero stat card — two prominent stat tiles (Pending + Clarification) on
  // top, full-width "Approved" highlight strip on the bottom. Replaces the
  // cramped 3-column-with-dividers layout.
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildHeroStats() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B45B0).withValues(alpha: 0.12),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: two stat tiles
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 16.h),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _heroStatTile(
                      icon: Icons.hourglass_top_rounded,
                      accent: AppColors.warningOrange,
                      accentBg: AppColors.amberBg,
                      label: 'Pending',
                      value: controller.pendingRequestsCount.value.toString(),
                      onTap: () => _openApprovalsTab(0),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60.h,
                    color: AppColors.slate100,
                  ),
                  Expanded(
                    child: _heroStatTile(
                      icon: Icons.help_outline_rounded,
                      accent: AppColors.primary,
                      accentBg: AppColors.purpleSurface,
                      label: 'Clarification',
                      value:
                          controller.inClarificationCount.value.toString(),
                      onTap: () => _openApprovalsTab(3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom: full-width Approved strip with gradient tint
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(22.r),
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.mintBg,
                  const Color(0xFFF0FDF4),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Obx(
              () => Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1410B981),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.successGreen,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'APPROVED THIS PERIOD',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF047857),
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '₹${CurrencyFormatter.inr(controller.approvedAmount.value)}',
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF064E3B),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStatTile({
    required IconData icon,
    required Color accent,
    required Color accentBg,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final inner = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accent, size: 18.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSlate,
              letterSpacing: 0.7,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return inner;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.04),
        child: inner,
      ),
    );
  }

  /// Pre-selects an Approvals sub-tab on the AdminApprovalsController and
  /// switches to the Approvals bottom-bar tab. Used by the dashboard stat
  /// tiles so they land directly on the right view.
  void _openApprovalsTab(int subTabIndex) {
    if (Get.isRegistered<AdminApprovalsController>()) {
      Get.find<AdminApprovalsController>().setInitialTab(subTabIndex);
    }
    controller.navigateToApprovals();
  }

  // ════════════════════════════════════════════════════════════════════════
  // Organization summary — single elegant card with row stats. Replaces
  // the three cramped tiles.
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildOrgSummaryCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          children: [
            _orgRow(
              icon: Icons.business_rounded,
              accent: AppColors.primary,
              accentBg: AppColors.purpleSurface,
              label: 'Total departments',
              value: controller.totalDepartments.value.toString(),
              showDivider: true,
              onTap: () => Get.toNamed(AppRoutes.ADMIN_DEPARTMENTS),
            ),
            _orgRow(
              icon: Icons.check_circle_outline_rounded,
              accent: AppColors.successGreen,
              accentBg: AppColors.mintBg,
              label: 'Active departments',
              value: controller.activeDepartments.value.toString(),
              showDivider: true,
              onTap: () => Get.toNamed(AppRoutes.ADMIN_DEPARTMENTS),
            ),
            _orgRow(
              icon: Icons.person_outline_rounded,
              accent: _blue,
              accentBg: _blueBg,
              label: 'Unassigned users',
              value: controller.unassignedUsers.value.toString(),
              showDivider: false,
              onTap: () => Get.toNamed(AppRoutes.ADMIN_USER_LIST),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orgRow({
    required IconData icon,
    required Color accent,
    required Color accentBg,
    required String label,
    required String value,
    required bool showDivider,
    VoidCallback? onTap,
  }) {
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accent, size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: _slate600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.2,
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded, color: AppColors.slate300, size: 18.sp),
          ],
        ],
      ),
    );

    final content = onTap == null
        ? row
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10.r),
              splashColor: accent.withValues(alpha: 0.08),
              highlightColor: accent.withValues(alpha: 0.04),
              child: row,
            ),
          );

    return Column(
      children: [
        content,
        if (showDivider) Container(height: 1, color: AppColors.slate100),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Section label + action tile.
  // ════════════════════════════════════════════════════════════════════════

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

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget Function()? trailingBuilder,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        splashColor: iconColor.withValues(alpha: 0.06),
        highlightColor: iconColor.withValues(alpha: 0.03),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: iconColor, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: _slate600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (trailingBuilder != null) ...[
                trailingBuilder(),
                SizedBox(width: 8.w),
              ],
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.slate300,
                  size: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countPill(int count, {required Color accent, required Color bg}) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Indian-grouping formatter (no decimals for the dashboard headline).
  /// 230000 → "2,30,000", 12345 → "12,345".

}
