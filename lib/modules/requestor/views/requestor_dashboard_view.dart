import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import 'package:cash/utils/formatters/greeting_formatter.dart';
import 'package:cash/utils/mappers/request_status_visuals.dart';
import 'package:cash/utils/mappers/expense_category_visuals.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/date_helper.dart';
import '../controllers/requestor_controller.dart';
import '../controllers/my_requests_controller.dart';

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
                  child: _buildHeroCard(),
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
                      _buildShimmerList()
                    else if (controller.dashboardError.value.isNotEmpty &&
                        controller.recentRequests.isEmpty)
                      _buildErrorState()
                    else if (controller.recentRequests.isEmpty)
                      _buildEmptyState()
                    else
                      _buildRecentList(context),
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
  // HERO CARD — twin stat tiles (Spent + Pending) on top, full-width
  // monthly limit progress strip on the bottom. Mirrors admin's hero card.
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildHeroCard() {
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
          // Top: two stat tiles ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 16.h),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _heroStatTile(
                      icon: Icons.account_balance_wallet_rounded,
                      accent: AppColors.primary,
                      accentBg: AppColors.purpleSurface,
                      label: 'Spent',
                      value:
                          '₹${CurrencyFormatter.inr(controller.amountSpent.value)}',
                    ),
                  ),
                  Container(width: 1, height: 60.h, color: AppColors.slate100),
                  Expanded(
                    child: _heroStatTile(
                      icon: Icons.hourglass_top_rounded,
                      accent: AppColors.warningOrange,
                      accentBg: AppColors.amberBg,
                      label: 'Pending',
                      value: controller.pendingCount.value.toString(),
                      onTap: () {
                        Get.find<MyRequestsController>().changeTab(1);
                        controller.changeTab(1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom: monthly limit progress strip ─────────────────────────
          Obx(() {
            final spent = controller.amountSpent.value;
            final limit = controller.monthlyLimit.value;
            final ratio = controller.progressRatio.value.clamp(0.0, 1.0);
            final overLimit = ratio > 0.85;
            return Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22.r),
                ),
                gradient: LinearGradient(
                  colors: overLimit
                      ? [AppColors.redBg, const Color(0xFFFEF7F7)]
                      : [AppColors.purpleSurface, const Color(0xFFF7F5FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  // Circular percent badge
                  SizedBox(
                    width: 44.w,
                    height: 44.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 44.w,
                          height: 44.w,
                          child: CircularProgressIndicator(
                            value: ratio,
                            strokeWidth: 5.w,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              overLimit ? AppColors.errorRed : AppColors.primary,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '${(ratio * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: overLimit ? AppColors.errorRed : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'MONTHLY LIMIT',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: overLimit
                                ? const Color(0xFF991B1B)
                                : const Color(0xFF4338CA),
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '₹${CurrencyFormatter.inr(spent)} of ₹${CurrencyFormatter.inr(limit)}',
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
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
                fontSize: 26.sp,
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
  // RECENT REQUESTS LIST
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildRecentList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.recentRequests.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final item = controller.recentRequests[i];
        final purpose = (item['purpose'] ?? 'Request').toString();
        final status = (item['status'] ?? 'pending').toString();
        final category = (item['category'] ?? '').toString();
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final dateStr = DateHelper.formatDate(item['date']?.toString());

        final statusColor = RequestStatusVisuals.colorFor(status);
        final statusBg = RequestStatusVisuals.bgFor(status);
        final iconColor = ExpenseCategoryVisuals.colorFor(category);
        final iconBg = ExpenseCategoryVisuals.bgFor(category);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            onTap: () =>
                Get.toNamed(AppRoutes.REQUEST_DETAILS_READ, arguments: item),
            borderRadius: BorderRadius.circular(16.r),
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            highlightColor: AppColors.primary.withValues(alpha: 0.04),
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
                    child: Icon(
                      ExpenseCategoryVisuals.iconFor(category),
                      color: iconColor,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purpose,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.textSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${CurrencyFormatter.inr(amount)}',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          RequestStatusVisuals.labelFor(status),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // EMPTY / ERROR / SHIMMER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48.sp, color: AppColors.slate300),
          SizedBox(height: 12.h),
          Text(
            'No recent requests',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSlate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.redBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 36.sp, color: AppColors.errorRed),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              controller.dashboardError.value,
              style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.errorRed),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: controller.fetchDashboard,
            child: Text('Retry', style: GoogleFonts.inter(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Container(
            height: 72.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                SizedBox(width: 14.w),
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.purpleSurface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12.h,
                        width: 120.w,
                        decoration: BoxDecoration(
                          color: AppColors.purpleSurface.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 10.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.purpleSurface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════════


  /// Indian grouping (₹1,23,456). Strips trailing .00 for whole numbers
  /// so the hero tiles don't run out of horizontal room.






}
