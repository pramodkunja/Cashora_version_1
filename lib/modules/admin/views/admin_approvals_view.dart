import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/mappers/request_status_visuals.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';
import '../utils/request_mapper.dart';
import '../controllers/admin_approvals_controller.dart';

class AdminApprovalsView extends StatefulWidget {
  const AdminApprovalsView({super.key});

  @override
  State<AdminApprovalsView> createState() => _AdminApprovalsViewState();
}

class _AdminApprovalsViewState extends State<AdminApprovalsView>
    with SingleTickerProviderStateMixin {
  late final AdminApprovalsController controller;
  late final TabController _tabController;
  late final Worker _initialTabWorker;


  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminApprovalsController>();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: controller.initialTabIndex.value.clamp(0, 4),
    );
    // Listen for external requests from the dashboard's stat tiles. When
    // `initialTabIndex` is updated, animate the local TabController to
    // match. Using an explicit controller + worker avoids the brittle
    // DefaultTabController + ValueKey rebuild dance that was sometimes
    // ignored by Flutter's element tree (leading to taps from the
    // dashboard landing on the wrong sub-tab).
    _initialTabWorker = ever<int>(controller.initialTabIndex, (idx) {
      final target = idx.clamp(0, 4);
      if (_tabController.index != target) {
        _tabController.animateTo(target);
      }
    });
  }

  @override
  void dispose() {
    _initialTabWorker.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTab(controller.pendingRequests, controller.pendingScroll),
                _buildTab(
                    controller.approvedRequests, controller.approvedScroll),
                _buildTab(controller.unpaidRequests, controller.unpaidScroll),
                _buildTab(controller.clarificationRequests,
                    controller.clarificationScroll),
                _buildTab(
                    controller.rejectedRequests, controller.rejectedScroll),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        22.h,
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
          Text(
            AppText.approvalsTitle,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.ADMIN_NOTIFICATIONS),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontally-scrollable chip rail. Replaces the stock Material
  /// TabBar so we can show a live count next to each label and have full
  /// control of the visual treatment (filled purple pill when active,
  /// white border-card when idle). Designed to never overflow on any
  /// phone width — chips size to their content and scroll horizontally.
  Widget _buildTabBar() {
    final labels = [
      AppText.tabPending,
      AppText.tabApproved,
      AppText.unpaid,
      AppText.clarification,
      AppText.tabRejected,
    ];
    return SizedBox(
      height: 56.h,
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (_, _) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 6.h),
            itemCount: labels.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (_, i) => _statusChip(
              label: labels[i],
              selected: _tabController.index == i,
              onTap: () => _tabController.animateTo(i),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 11.h),
        decoration: BoxDecoration(
          // Inactive: solid slate-200 so chips pop against the slate-50
          // page bg. Active: brand purple.
          color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.32),
                    blurRadius: 14.r,
                    offset: Offset(0, 5.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
      RxList<Map<String, dynamic>> list, ScrollController scroll) {
    return Obx(() {
      if (controller.isLoading.value && list.isEmpty) {
        return const SkeletonListView();
      }
      if (list.isEmpty) return _buildEmptyState();
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.fetchAllRequests,
        child: ListView.separated(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
          itemCount: list.length,
          separatorBuilder: (_, _) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => _buildCard(list[i]),
        ),
      );
    });
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final title =
        (item['title'] ?? item['purpose'] ?? AppText.unnamedRequest).toString();
    final user = RequestMapper.getUserName(item);
    final amount = (item['amount'] is num)
        ? (item['amount'] as num).toDouble()
        : double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;
    final department = RequestMapper.getDepartment(item);
    final rawStatus = (item['status'] ?? 'pending').toString().toLowerCase();
    final dateStr = RequestMapper.formatDate(item['date'] ?? item['created_at']);

    final statusColor = RequestStatusVisuals.colorFor(rawStatus);
    final statusBg = RequestStatusVisuals.bgFor(rawStatus);
    final statusLabel = RequestStatusVisuals.labelFor(rawStatus);

    // Show an UNPAID tag when an approved request still has the payment
    // outstanding (status=approved/auto_approved AND payment_status=pending).
    final paymentStatus =
        item['payment_status']?.toString().toLowerCase() ?? '';
    final isApprovedStatus =
        rawStatus == 'approved' || rawStatus == 'auto_approved';
    final showUnpaidTag =
        isApprovedStatus && paymentStatus == 'pending';

    return GestureDetector(
      onTap: () => controller.navigateToDetails(item),
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.purpleSurface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: AppColors.primary, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.apartment_rounded,
                              size: 11.sp, color: AppColors.textSlate),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              department,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.textSlate,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (showUnpaidTag) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.amberBg,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppColors.warningOrange.withValues(alpha: 0.35),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.payments_outlined,
                                size: 9.sp, color: AppColors.warningOrange),
                            SizedBox(width: 3.w),
                            Text(
                              'UNPAID',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.warningOrange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSlate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
            SizedBox(height: 12.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundColor: AppColors.purpleSurface,
                  child: Text(
                    RequestMapper.getInitials(user),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requested by',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: AppColors.textSlate,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        user,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 56.sp, color: AppColors.slate300),
          SizedBox(height: 14.h),
          Text(
            AppText.noRequests,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSlate,
            ),
          ),
        ],
      ),
    );
  }



}
