import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';
import '../utils/request_mapper.dart';
import '../controllers/admin_approvals_controller.dart';

class AdminApprovalsView extends GetView<AdminApprovalsController> {
  const AdminApprovalsView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _red = AppColors.errorRed;
  static const _redBg = Color(0xFFFEF2F2);
  static const _amber = AppColors.warningOrange;
  static const _amberBg = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTab(controller.pendingRequests,
                      controller.pendingScroll),
                  _buildTab(controller.approvedRequests,
                      controller.approvedScroll),
                  _buildTab(controller.unpaidRequests,
                      controller.unpaidScroll),
                  _buildTab(controller.clarificationRequests,
                      controller.clarificationScroll),
                  _buildTab(controller.rejectedRequests,
                      controller.rejectedScroll),
                ],
              ),
            ),
          ],
        ),
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
                color: Colors.white.withOpacity(0.15),
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

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
      height: 38.h,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          color: _purple,
          borderRadius: BorderRadius.circular(100.r),
        ),
        indicatorPadding:
            EdgeInsets.symmetric(horizontal: -14.w, vertical: 4.h),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: _slate500,
        labelStyle: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: 18.w),
        overlayColor:
            WidgetStateProperty.all(_purple.withOpacity(0.06)),
        tabs: [
          Tab(text: AppText.tabPending),
          Tab(text: AppText.tabApproved),
          Tab(text: AppText.unpaid),
          Tab(text: AppText.clarification),
          Tab(text: AppText.tabRejected),
        ],
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
        color: _purple,
        onRefresh: controller.fetchAllRequests,
        child: ListView.separated(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
          itemCount: list.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
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

    final statusColor = _colorForStatus(rawStatus);
    final statusBg = _bgForStatus(rawStatus);
    final statusLabel = _statusLabel(rawStatus);

    return GestureDetector(
      onTap: () => controller.navigateToDetails(item),
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: _purple, size: 22.sp),
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
                          color: _slate900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.apartment_rounded,
                              size: 11.sp, color: _slate500),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              department,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: _slate500,
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
                    SizedBox(height: 4.h),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: _slate500,
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
                  backgroundColor: _purpleLight,
                  child: Text(
                    RequestMapper.getInitials(user),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: _purple,
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
                          color: _slate500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        user,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _slate900,
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
                    color: _slate900,
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
          Icon(Icons.inbox_rounded, size: 56.sp, color: _slate300),
          SizedBox(height: 14.h),
          Text(
            AppText.noRequests,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: _slate500,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForStatus(String status) {
    if (status.contains('approved') || status.contains('paid')) return _green;
    if (status.contains('rejected')) return _red;
    if (status.contains('clarification')) return _purple;
    return _amber;
  }

  Color _bgForStatus(String status) {
    if (status.contains('approved') || status.contains('paid')) return _greenBg;
    if (status.contains('rejected')) return _redBg;
    if (status.contains('clarification')) return _purpleLight;
    return _amberBg;
  }

  String _statusLabel(String status) {
    if (status == 'auto_approved') return 'APPROVED';
    if (status.contains('clarification')) return 'CLARIFICATION';
    return status.toUpperCase();
  }
}
