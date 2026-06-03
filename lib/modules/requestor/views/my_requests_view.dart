import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/my_requests_controller.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/mappers/request_status_visuals.dart';
import 'package:cash/utils/mappers/expense_category_visuals.dart';
import '../../../utils/widgets/skeletons/skeleton_loader.dart';

class MyRequestsView extends GetView<MyRequestsController> {
  const MyRequestsView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
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
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
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
        backgroundColor: AppColors.primary,
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
                color: Colors.white.withValues(alpha: 0.18),
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
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.searchRequests,
          style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: AppText.searchRequests,
            hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.slate300),
            prefixIcon:
                Icon(Icons.search_rounded, color: AppColors.textSlate, size: 20.sp),
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
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSlate,
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

    final statusColor = RequestStatusVisuals.colorFor(status);
    final statusBg = RequestStatusVisuals.bgFor(status);
    final statusText = RequestStatusVisuals.labelFor(status);
    final iconData = ExpenseCategoryVisuals.iconFor(purpose);
    final showUnpaidTag = _isApprovedUnpaid(req);

    return GestureDetector(
      onTap: () => controller.viewDetails(req),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category icon
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.purpleSurface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(iconData, color: AppColors.primary, size: 22.sp),
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
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 11.sp, color: AppColors.textSlate),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              '$date • $category',
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
                // Amount + status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
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
                    if (showUnpaidTag) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.amberBg,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 10.sp, color: AppColors.warningOrange),
                            SizedBox(width: 3.w),
                            Text(
                              'UNPAID',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warningOrange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: AppColors.errorRed, size: 14.sp),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        (req['rejection_reason'] ??
                                'Missing information or receipt attachment')
                            .toString(),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.errorRed,
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
          Icon(Icons.inbox_rounded, size: 56.sp, color: AppColors.slate300),
          SizedBox(height: 14.h),
          Text(
            'No requests found',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSlate,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap the + button to create one',
            style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.slate300),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════════

  String _inferCategory(String purpose) {
    final p = purpose.toLowerCase();
    if (p.contains('food')) return 'Food';
    if (p.contains('travel') || p.contains('flight')) return 'Travel';
    if (p.contains('supplies')) return 'Inventory';
    return 'General';
  }




  /// True when the request is approved but the accountant has not yet
  /// settled payment — used to render the secondary "UNPAID" badge so the
  /// requestor can tell at a glance which approved items are still pending
  /// payout.
  ///
  /// Signals (any one is enough):
  ///   - `payment_status == 'unpaid' | 'pending'`
  ///   - status is `approved`/`auto_approved` AND no `payment_method` set
  bool _isApprovedUnpaid(Map<String, dynamic> req) {
    final status = (req['status'] ?? '').toString().toLowerCase();
    final paymentStatus =
        (req['payment_status'] ?? '').toString().toLowerCase();
    final paymentMethod =
        (req['payment_method'] ?? '').toString().trim().toLowerCase();
    final txnRef = (req['transaction_reference'] ?? '').toString().trim();

    // Don't show on non-approved states (rejected/pending/clarification).
    final isApprovedState =
        status == 'approved' || status == 'auto_approved' || status == 'unpaid';
    if (!isApprovedState) return false;

    // Already paid → hide.
    if (status == 'paid' ||
        paymentStatus == 'paid' ||
        paymentMethod.isNotEmpty ||
        txnRef.isNotEmpty) {
      return false;
    }

    // Approved + no payment trail → unpaid.
    return true;
  }
}
