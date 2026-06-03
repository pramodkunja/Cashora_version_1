import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import 'package:cash/utils/formatters/greeting_formatter.dart';
import 'package:cash/utils/mappers/expense_category_visuals.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/date_helper.dart';
import '../../../../utils/widgets/skeletons/page_skeletons.dart';
import '../controllers/accountant_dashboard_controller.dart';
import 'cash_flow_history_view.dart';

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
              SliverToBoxAdapter(child: _buildHeader(context)),

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
                  sliver: SliverToBoxAdapter(child: _buildErrorState()),
                ),
              ] else if (data != null) ...[
                // Hero stat card overlapping the gradient header.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: _buildHeroCard(
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
                        _buildEmptyTransactions()
                      else
                        _buildTransactionList(data.todayTransactions),
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
  // HEADER — gradient purple with greeting + name + date + bell
  // (Identical pattern to admin + requestor dashboards.)
  // ════════════════════════════════════════════════════════════════════
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
            onTap: () => Get.toNamed(AppRoutes.ACCOUNTANT_NOTIFICATIONS),
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

  // ════════════════════════════════════════════════════════════════════
  // HERO CARD — twin balance tiles on top, full-width "In Hand Cash"
  // strip on the bottom. Same pattern as admin / requestor heroes.
  // ════════════════════════════════════════════════════════════════════
  Widget _buildHeroCard({
    required double open,
    required double closing,
    required double inHand,
    required String growth,
  }) {
    final isPositive =
        growth.trim().startsWith('+') || (!growth.contains('-') && growth.isNotEmpty);
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
          // Top: balance tiles
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: _heroStatTile(
                    icon: Icons.lock_clock_rounded,
                    accent: AppColors.primary,
                    accentBg: AppColors.purpleSurface,
                    label: AppText.openBalance,
                    value: '₹${CurrencyFormatter.inr(open)}',
                  ),
                ),
                Container(width: 1, height: 60.h, color: AppColors.slate100),
                Expanded(
                  child: _heroStatTile(
                    icon: Icons.lock_rounded,
                    accent: AppColors.primary,
                    accentBg: AppColors.purpleSurface,
                    label: AppText.closingBalance,
                    value: '₹${CurrencyFormatter.inr(closing)}',
                  ),
                ),
              ],
            ),
          ),
          // Bottom: full-width IN HAND CASH strip
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
            child: Row(
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
                    Icons.account_balance_wallet_rounded,
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
                        'IN HAND CASH',
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
                          '₹${CurrencyFormatter.inr(inHand)}',
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
                if (growth.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 12.sp,
                          color: isPositive ? AppColors.successGreen : AppColors.errorRed,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          growth,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: isPositive ? AppColors.successGreen : AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
  }) {
    return Padding(
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
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.1,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
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

  // ════════════════════════════════════════════════════════════════════
  // TRANSACTIONS LIST — category-tinted icons (no more all-purple)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildTransactionList(List transactions) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final tx = transactions[i];
        final amount = (tx.amount as num).toDouble();
        final isExpense = amount < 0;
        final iconType = tx.iconType.toString().toLowerCase();
        final iconColor = ExpenseCategoryVisuals.colorFor(iconType);
        final iconBg = ExpenseCategoryVisuals.bgFor(iconType);

        return Container(
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
                  ExpenseCategoryVisuals.iconFor(iconType),
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
                      tx.title.toString(),
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
                      tx.subtitle.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.textSlate,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${isExpense ? '-' : '+'}₹${CurrencyFormatter.inr(amount.abs())}',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: isExpense ? AppColors.errorRed : AppColors.successGreen,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyTransactions() {
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
            'No transactions today',
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
              controller.errorMessage.value,
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

  // ─── Helpers ─────────────────────────────────────────────────────────

  /// Indian grouping (₹1,23,456). Drops the decimals for whole rupees so
  /// the hero values don't run out of horizontal room.



}
