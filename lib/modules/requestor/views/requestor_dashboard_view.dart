import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/date_helper.dart';
import '../controllers/requestor_controller.dart';
import '../controllers/my_requests_controller.dart';

class RequestorDashboardView extends GetView<RequestorController> {
  const RequestorDashboardView({Key? key}) : super(key: key);

  // ─── Palette (same app colors, derived shades) ───────────────────────
  static const _purple = AppColors.primary; // 0xFF6B55CE
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _red = AppColors.errorRed;
  static const _redBg = Color(0xFFFEF2F2);
  static const _amber = AppColors.warningOrange;
  static const _amberBg = Color(0xFFFFFBEB);
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        final loading = controller.isDashboardLoading.value;
        return RefreshIndicator(
          color: _purple,
          onRefresh: controller.fetchDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(context)),
              // ── Body ────────────────────────────────────────
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 24.h),
                    _buildSpendCard(),
                    SizedBox(height: 16.h),
                    _buildQuickActions(),
                    SizedBox(height: 24.h),
                    _buildPendingBanner(),
                    SizedBox(height: 28.h),
                    _buildSectionHeader(
                      AppText.recentRequests,
                      onSeeAll: () {
                        Get.find<MyRequestsController>().changeTab(0);
                        controller.changeTab(1);
                      },
                    ),
                    SizedBox(height: 14.h),
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
      padding: EdgeInsets.fromLTRB(24.w, MediaQuery.of(context).padding.top + 16.h, 24.w, 28.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row — greeting + bell
          Row(
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
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.REQUESTOR_NOTIFICATIONS),
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
          SizedBox(height: 6.h),
          Text(
            DateHelper.getFormattedDate(),
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // SPEND CARD  — monthly expense with progress ring
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSpendCard() {
    return Obx(() {
      final spent = controller.amountSpent.value;
      final limit = controller.monthlyLimit.value;
      final ratio = controller.progressRatio.value.clamp(0.0, 1.0);

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(0.06),
              blurRadius: 20.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Progress ring
            SizedBox(
              width: 72.w,
              height: 72.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72.w,
                    height: 72.w,
                    child: CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 7.w,
                      backgroundColor: _purpleLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ratio > 0.85 ? _red : _purple,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(ratio * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _slate900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.monthlyExpense,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _slate500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '₹${spent.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: _slate900,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'of ₹${limit.toStringAsFixed(0)} ${AppText.limit}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _slate500,
                    ),
                  ),
                ],
              ),
            ),
            // View Details chevron
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.MONTHLY_SPENT),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: _purple,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  // QUICK ACTIONS  — single full-width "New Request" button
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: () => Get.toNamed(AppRoutes.CREATE_REQUEST_TYPE),
        icon: Icon(Icons.add_rounded, size: 22.sp),
        label: Text(
          AppText.newRequest,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // PENDING BANNER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildPendingBanner() {
    return Obx(() {
      final count = controller.pendingCount.value;
      return GestureDetector(
        onTap: () {
          Get.find<MyRequestsController>().changeTab(1);
          controller.changeTab(1);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _purpleLight, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: _purple,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.pendingApprovals,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _slate900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$count ${AppText.requestsWaiting}',
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
                size: 24.sp,
              ),
            ],
          ),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _slate900,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _purple,
              ),
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
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final item = controller.recentRequests[i];
        final purpose = (item['purpose'] ?? 'Request').toString();
        final status = (item['status'] ?? 'pending').toString();
        final category = (item['category'] ?? '').toString();
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final dateStr = _formatDate(item['date']);

        final statusColor = _colorForStatus(status);
        final statusBg = _bgForStatus(status);

        return GestureDetector(
          onTap: () =>
              Get.toNamed(AppRoutes.REQUEST_DETAILS_READ, arguments: item),
          child: Container(
            padding: EdgeInsets.all(14.w),
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
                // Category icon
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _iconForCategory(category),
                    color: _purple,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purpose,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _slate900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: _slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Amount + status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: _slate900,
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
                        _statusLabel(status),
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
          Icon(Icons.inbox_rounded, size: 48.sp, color: _slate300),
          SizedBox(height: 12.h),
          Text(
            'No recent requests',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: _slate500,
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
        color: _redBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 36.sp, color: _red),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              controller.dashboardError.value,
              style: GoogleFonts.inter(fontSize: 13.sp, color: _red),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: controller.fetchDashboard,
            child: Text('Retry', style: GoogleFonts.inter(color: _purple)),
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
                    color: _purpleLight.withOpacity(0.5),
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
                          color: _purpleLight.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 10.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: _purpleLight.withOpacity(0.3),
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
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatDate(dynamic iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso.toString());
    if (dt == null) return iso.toString();
    return DateHelper.formatDate(dt.toIso8601String());
  }

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('food') || c.contains('meal')) return Icons.restaurant_rounded;
    if (c.contains('travel') || c.contains('flight')) return Icons.flight_rounded;
    if (c.contains('transport') || c.contains('taxi')) return Icons.directions_car_rounded;
    if (c.contains('office') || c.contains('supplies')) return Icons.shopping_bag_rounded;
    return Icons.receipt_long_rounded;
  }

  Color _colorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'auto_approved':
      case 'paid':
        return _green;
      case 'rejected':
        return _red;
      case 'clarification':
        return _purple;
      default:
        return _amber;
    }
  }

  Color _bgForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'auto_approved':
      case 'paid':
        return _greenBg;
      case 'rejected':
        return _redBg;
      case 'clarification':
        return _purpleLight;
      default:
        return _amberBg;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'auto_approved':
        return 'Approved';
      case 'clarification':
        return 'Clarification';
      default:
        return status.isEmpty
            ? '-'
            : status[0].toUpperCase() + status.substring(1);
    }
  }
}
