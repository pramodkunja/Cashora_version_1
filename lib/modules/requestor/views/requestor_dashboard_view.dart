import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/formatters/greeting_formatter.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/date_helper.dart';
import '../controllers/requestor_controller.dart';
import '../controllers/my_requests_controller.dart';
import 'widgets/requestor_recent_section.dart';
import 'widgets/requestor_hero_card.dart';

class RequestorDashboardView extends GetView<RequestorController> {
  const RequestorDashboardView({super.key});

  // ─── Palette ────────────────────────────────────────────────────────
  static const _blue = Color(0xFF0EA5E9);
  static const _blueBg = Color(0xFFE0F2FE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Obx(() {
        final loading = controller.isDashboardLoading.value;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),

              // Hero card overlaps the gradient header — same pattern as
              // the admin dashboard so the two flows feel cohesive.
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0.h),
                  child: RequestorHeroCard(
                    amountSpent: controller.amountSpent.value,
                    pendingCount: controller.pendingCount.value,
                    monthlyLimit: controller.monthlyLimit.value,
                    progressRatio: controller.progressRatio.value,
                    onPendingTap: () {
                      Get.find<MyRequestsController>().changeTab(1);
                      controller.changeTab(1);
                    },
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 40.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionLabel('QUICK ACTIONS'),
                    SizedBox(height: 12.h),
                    _buildActionTile(
                      icon: Icons.add_circle_outline_rounded,
                      iconColor: AppColors.primary,
                      iconBg: AppColors.purpleSurface,
                      title: AppText.newRequest,
                      subtitle: 'Submit a new expense or advance',
                      onTap: () =>
                          Get.toNamed(AppRoutes.CREATE_REQUEST_TYPE),
                    ),
                    SizedBox(height: 12.h),
                    _buildActionTile(
                      icon: Icons.hourglass_top_rounded,
                      iconColor: AppColors.warningOrange,
                      iconBg: AppColors.amberBg,
                      title: AppText.pendingApprovals,
                      subtitle: 'Requests awaiting admin review',
                      onTap: () {
                        Get.find<MyRequestsController>().changeTab(1);
                        controller.changeTab(1);
                      },
                      trailingBuilder: () => Obx(
                        () => _countPill(
                          controller.pendingCount.value,
                          accent: AppColors.warningOrange,
                          bg: AppColors.amberBg,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildActionTile(
                      icon: Icons.history_rounded,
                      iconColor: _blue,
                      iconBg: _blueBg,
                      title: 'All Requests',
                      subtitle: 'View past and active requests',
                      onTap: () {
                        Get.find<MyRequestsController>().changeTab(0);
                        controller.changeTab(1);
                      },
                    ),

                    SizedBox(height: 28.h),
                    _buildSectionHeader(
                      AppText.recentRequests,
                      onSeeAll: () {
                        Get.find<MyRequestsController>().changeTab(0);
                        controller.changeTab(1);
                      },
                    ),
                    SizedBox(height: 12.h),
                    if (loading && controller.recentRequests.isEmpty)
                      const RequestorRecentShimmer()
                    else if (controller.dashboardError.value.isNotEmpty &&
                        controller.recentRequests.isEmpty)
                      RequestorRecentError(
                        message: controller.dashboardError.value,
                        onRetry: controller.fetchDashboard,
                      )
                    else if (controller.recentRequests.isEmpty)
                      const RequestorRecentEmpty()
                    else
                      RequestorRecentList(
                        items: controller.recentRequests.toList(),
                        onTap: (item) => Get.toNamed(
                          AppRoutes.REQUEST_DETAILS_READ,
                          arguments: item,
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // HEADER  — gradient purple header with greeting + notification bell
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
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11.sp,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
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
            onTap: () => Get.toNamed(AppRoutes.REQUESTOR_NOTIFICATIONS),
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
  // ACTION TILE — colored icon + text + optional trailing pill/chevron.
  // Identical pattern to admin dashboard so flows feel cohesive.
  // ════════════════════════════════════════════════════════════════════════
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
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        splashColor: iconColor.withValues(alpha: 0.08),
        highlightColor: iconColor.withValues(alpha: 0.04),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12.r,
                offset: Offset(0, 3.h),
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
                  borderRadius: BorderRadius.circular(12.r),
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
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSlate,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              trailingBuilder?.call() ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.slate300,
                    size: 22.sp,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countPill(int count, {required Color accent, required Color bg}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        count.toString(),
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textSlate,
        letterSpacing: 1.0,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION HEADER (with "See all" affordance)
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(Icons.arrow_forward_rounded, size: 14.sp, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════════


  /// Indian grouping (₹1,23,456). Strips trailing .00 for whole numbers
  /// so the hero tiles don't run out of horizontal room.






}
