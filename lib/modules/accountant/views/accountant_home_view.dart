import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/skeletons/page_skeletons.dart';
import '../controllers/accountant_dashboard_controller.dart';
import 'cash_flow_history_view.dart';
import 'widgets/accountant_home_hero_card.dart';
import 'widgets/accountant_home_transactions.dart';
import 'widgets/accountant_home_header.dart';

class AccountantHomeView extends GetView<AccountantDashboardController> {
  const AccountantHomeView({super.key});

  // ─── Palette (same tokens used by admin / requestor) ─────────────────
  static const _blue = Color(0xFF0EA5E9);
  static const _blueBg = Color(0xFFE0F2FE);
  static const _pink = Color(0xFFEC4899);
  static const _pinkBg = Color(0xFFFCE7F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Obx(() {
        final loading = controller.isDashboardLoading.value;
        final data = controller.dashboardData.value;
        final isFirstLoad = loading && data == null;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AccountantHomeHeader(
                  shortName: controller.shortName,
                  onBellTap: () =>
                      Get.toNamed(AppRoutes.ACCOUNTANT_NOTIFICATIONS),
                ),
              ),

              if (isFirstLoad) ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
                  sliver: const SliverToBoxAdapter(
                    child: AccountantDashboardSkeleton(),
                  ),
                ),
              ] else if (controller.errorMessage.isNotEmpty &&
                  data == null) ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 100.h),
                  sliver: SliverToBoxAdapter(
                    child: AccountantHomeErrorState(
                      message: controller.errorMessage.value,
                      onRetry: controller.fetchDashboard,
                    ),
                  ),
                ),
              ] else if (data != null) ...[
                // Hero stat card overlapping the gradient header.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: AccountantHomeHeroCard(
                      open: data.accountOverview.openBalance,
                      closing: data.accountOverview.closingBalance,
                      inHand: data.accountOverview.inHandCash,
                      growth: data.accountOverview.inHandCashGrowth,
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
                        icon: Icons.payments_rounded,
                        iconColor: AppColors.warningOrange,
                        iconBg: AppColors.amberBg,
                        title: AppText.pendingPayments,
                        subtitle:
                            '${data.tasksSummary.pendingPaymentsCount} ${AppText.paymentsNeedProcessing}',
                        onTap: controller.navigateToPayments,
                        trailingBuilder: () => _countPill(
                          data.tasksSummary.pendingPaymentsCount,
                          accent: AppColors.warningOrange,
                          bg: AppColors.amberBg,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildActionTile(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: AppColors.successGreen,
                        iconBg: AppColors.mintBg,
                        title: 'Manage Balances',
                        subtitle: 'Update opening & closing balances',
                        onTap: () => Get.toNamed(
                            AppRoutes.ACCOUNTANT_MANAGE_BALANCES),
                      ),
                      SizedBox(height: 12.h),
                      _buildActionTile(
                        icon: Icons.insights_rounded,
                        iconColor: _blue,
                        iconBg: _blueBg,
                        title: 'Spend Analytics',
                        subtitle: 'Insights into your spending',
                        onTap: () => controller.changeTabIndex(2),
                      ),
                      SizedBox(height: 12.h),
                      _buildActionTile(
                        icon: Icons.history_rounded,
                        iconColor: _pink,
                        iconBg: _pinkBg,
                        title: 'Cash Flow History',
                        subtitle: 'Today\'s detailed transactions',
                        onTap: () =>
                            Get.to(() => const CashFlowHistoryView()),
                      ),
                      SizedBox(height: 28.h),
                      _buildSectionHeader(
                        AppText.todayTransactions,
                        onSeeAll: () =>
                            Get.to(() => const CashFlowHistoryView()),
                      ),
                      SizedBox(height: 12.h),
                      if (data.todayTransactions.isEmpty)
                        const AccountantHomeEmptyTransactions()
                      else
                        AccountantHomeTransactionList(
                          transactions: data.todayTransactions,
                        ),
                    ]),
                  ),
                ),
              ] else ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 80.h, 20.w, 100.h),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'No data available',
                        style: GoogleFonts.inter(
                            fontSize: 14.sp, color: AppColors.textSlate),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // ACTION TILE — colored icon disc + text + optional trailing pill/chev
  // (Identical to the admin & requestor action tile pattern.)
  // ════════════════════════════════════════════════════════════════════
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

  // ════════════════════════════════════════════════════════════════════
  // SECTION HEADER (with "See all" affordance)
  // ════════════════════════════════════════════════════════════════════
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

  // ─── Helpers ─────────────────────────────────────────────────────────

  /// Indian grouping (₹1,23,456). Drops the decimals for whole rupees so
  /// the hero values don't run out of horizontal room.



}
