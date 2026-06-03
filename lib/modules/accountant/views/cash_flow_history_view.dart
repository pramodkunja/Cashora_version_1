import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/cash_flow_history_controller.dart';
import 'widgets/cash_flow_transaction_card.dart';
import 'widgets/cash_flow_hero_card.dart';
import 'widgets/cash_flow_skeletons.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';

/// "Today's Transactions" view-all screen — opened from the accountant
/// home dashboard's "View All" link.
///
/// Design matches the rest of the app: gradient purple header, white
/// hero summary card overlapping the header, slate-50 body, white
/// transaction rows with soft drop shadows. Each row is tappable and
/// opens the completed-payment / pending details flow.
class CashFlowHistoryView extends GetView<CashFlowHistoryController> {
  const CashFlowHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CashFlowHistoryController());
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      // Keep RefreshIndicator + CustomScrollView OUTSIDE Obx so the
      // scroll view, its physics, the refresh gesture and every
      // InkWell/MouseRegion inside the rendered tree stay stable
      // across data changes. Reactive bits each get their own narrow
      // Obx below — this avoids the mouse_tracker assertion that
      // fires when the entire tree is torn down/rebuilt during a
      // hit-test frame.
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.fetch,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: Obx(() {
                  if (_isFirstPaintLoading) return const CashFlowHeroSkeleton();
                  return CashFlowHeroCard(
                    totalIn: controller.totalIn.value,
                    totalOut: controller.totalOut.value,
                    net: controller.net.value,
                  );
                }),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h),
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  if (_isFirstPaintLoading) return const CashFlowBodySkeleton();
                  return _buildBody();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// True while the very first fetch is in flight — no data yet AND no
  /// error. Drives the skeleton-vs-real-content switch on first paint
  /// only; subsequent refreshes keep showing existing data so there is
  /// no flicker.
  bool get _isFirstPaintLoading =>
      controller.isLoading.value &&
      controller.transactions.isEmpty &&
      controller.errorMessage.value.isEmpty;

  // ════════════════════════════════════════════════════════════════════
  // HEADER — gradient purple bar with back button + title + date
  // ════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        24.h,
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
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Today's Transactions",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11.sp,
                        color: Colors.white.withValues(alpha: 0.75)),
                    SizedBox(width: 6.w),
                    Obx(() => Text(
                          _formatDateBadge(controller.date.value),
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Obx(() {
            final c = controller.count.value;
            if (c == 0) return const SizedBox.shrink();
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                '$c',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // BODY — list / loading / error / empty
  // ════════════════════════════════════════════════════════════════════
  Widget _buildBody() {
    if (controller.isLoading.value && controller.transactions.isEmpty) {
      return const SkeletonListView();
    }
    if (controller.errorMessage.value.isNotEmpty &&
        controller.transactions.isEmpty) {
      return _buildErrorState();
    }
    if (controller.transactions.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('ALL TRANSACTIONS'),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.transactions.length,
          separatorBuilder: (_, _) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => CashFlowTransactionCard(
            tx: controller.transactions[i],
            onTap: () => _openDetails(controller.transactions[i]),
          ),
        ),
      ],
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

  // ════════════════════════════════════════════════════════════════════
  // EMPTY / ERROR STATES
  // ════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 56.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 56.sp, color: AppColors.slate300),
          SizedBox(height: 14.h),
          Text(
            'No transactions today',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Payouts processed today will appear here',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
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
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.redBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 40.sp, color: AppColors.errorRed),
          SizedBox(height: 10.h),
          Obx(() => Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorRed,
                ),
              )),
          SizedBox(height: 14.h),
          TextButton.icon(
            onPressed: controller.fetch,
            icon: Icon(Icons.refresh_rounded, size: 16.sp, color: AppColors.primary),
            label: Text(
              'Retry',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // NAV — tap a row → open completed/pending details. The completed
  // details view already accepts a request map via Get.arguments AND
  // its controller will refetch the latest shape via the new
  // /accountant/transactions/{id} endpoint once it's wired (see the
  // requestor's RequestDetailsReadView for the same pattern).
  // ════════════════════════════════════════════════════════════════════
  void _openDetails(Map<String, dynamic> tx) {
    final paymentStatus = (tx['payment_status'] ?? '').toString().toLowerCase();
    final status = (tx['status'] ?? '').toString().toLowerCase();
    final isPaid = status == 'paid' || paymentStatus == 'paid';
    if (isPaid) {
      // CompletedRequestDetailsController expects the flat row map; it
      // then refetches via GET /accountant/transactions/{id} to merge
      // the full shape (audit_trail, payment_method, etc.).
      Get.toNamed(
        AppRoutes.ACCOUNTANT_PAYMENT_COMPLETED_DETAILS,
        arguments: tx,
      );
    } else {
      // PaymentFlowController expects `{ 'request': tx, ... }` so it
      // can pick up the amount + bill image from the right keys.
      Get.toNamed(
        AppRoutes.ACCOUNTANT_PAYMENT_BILL_DETAILS,
        arguments: {
          'request': tx,
          'url': tx['payment_qr_url'] ?? tx['receipt_url'] ?? '',
          'title': tx['purpose'] ?? tx['title'] ?? 'Payment Request',
        },
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════
  String _formatDateBadge(String iso) {
    if (iso.isEmpty) {
      final now = DateTime.now();
      return _ddMonYY(now);
    }
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return _ddMonYY(dt);
  }

  String _ddMonYY(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
