import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/my_requests_controller.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_colors.dart';
import '../../../utils/widgets/skeletons/skeleton_loader.dart';

class MyRequestsView extends GetView<MyRequestsController> {
  const MyRequestsView({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearch(),
          SizedBox(height: 12.h),
          _buildFilterChips(),
          SizedBox(height: 14.h),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const SkeletonListView();
              }
              if (controller.filteredRequests.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.separated(
                controller: controller.scrollController,
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                itemCount: controller.filteredRequests.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final req = controller.filteredRequests[i];
                  return _buildRequestCard(req);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.CREATE_REQUEST_TYPE),
        backgroundColor: _purple,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        icon: Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
        label: Text(
          'New Request',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════
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
            AppText.myRequests,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Obx(
            () => Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${controller.filteredRequests.length} items',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.searchRequests,
          style: GoogleFonts.inter(fontSize: 14.sp, color: _slate900),
          decoration: InputDecoration(
            hintText: AppText.searchRequests,
            hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: _slate300),
            prefixIcon:
                Icon(Icons.search_rounded, color: _slate500, size: 20.sp),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // FILTER CHIPS
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(
        () => Row(
          children: [
            _chip(AppText.filterAll, 0),
            SizedBox(width: 8.w),
            _chip(AppText.filterPending, 1),
            SizedBox(width: 8.w),
            _chip(AppText.filterClarification, 5),
            SizedBox(width: 8.w),
            _chip(AppText.filterApproved, 2),
            SizedBox(width: 8.w),
            _chip(AppText.filterRejected, 3),
            SizedBox(width: 8.w),
            _chip('Unpaid', 4),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int index) {
    final selected = controller.currentTab.value == index;
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? _purple : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _slate500,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // REQUEST CARD
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = (req['status'] ?? 'pending').toString().toLowerCase();
    final purpose =
        (req['purpose'] ?? req['title'] ?? 'Request').toString();
    final date = (req['date'] ?? 'No Date').toString();
    final category =
        (req['category'] ?? _inferCategory(purpose)).toString();
    final amount = (req['amount'] as num?)?.toDouble() ?? 0.0;

    final statusColor = _colorForStatus(status);
    final statusBg = _bgForStatus(status);
    final statusText = _statusLabel(status);
    final iconData = _iconForCategory(purpose);

    return GestureDetector(
      onTap: () => controller.viewDetails(req),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category icon
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(iconData, color: _purple, size: 22.sp),
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
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 11.sp, color: _slate500),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              '$date • $category',
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
                // Amount + status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: _slate900,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Rejection reason pill
            if (status == 'rejected') ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _redBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: _red, size: 14.sp),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        (req['rejection_reason'] ??
                                'Missing information or receipt attachment')
                            .toString(),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: _red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 56.sp, color: _slate300),
          SizedBox(height: 14.h),
          Text(
            'No requests found',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _slate500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap the + button to create one',
            style: GoogleFonts.inter(fontSize: 13.sp, color: _slate300),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════════
  IconData _iconForCategory(String purpose) {
    final p = purpose.toLowerCase();
    if (p.contains('food') || p.contains('lunch') || p.contains('dinner'))
      return Icons.restaurant_rounded;
    if (p.contains('taxi') || p.contains('transport') || p.contains('uber'))
      return Icons.directions_car_rounded;
    if (p.contains('flight') ||
        p.contains('trip') ||
        p.contains('travel'))
      return Icons.flight_rounded;
    if (p.contains('supplies') || p.contains('inventory'))
      return Icons.shopping_bag_rounded;
    return Icons.receipt_long_rounded;
  }

  String _inferCategory(String purpose) {
    final p = purpose.toLowerCase();
    if (p.contains('food')) return 'Food';
    if (p.contains('travel') || p.contains('flight')) return 'Travel';
    if (p.contains('supplies')) return 'Inventory';
    return 'General';
  }

  Color _colorForStatus(String status) {
    switch (status) {
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
    switch (status) {
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
    switch (status) {
      case 'auto_approved':
        return 'APPROVED';
      case 'clarification':
        return 'CLARIFICATION';
      default:
        return status.toUpperCase();
    }
  }
}
