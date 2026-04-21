import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/date_helper.dart';
import '../../../../utils/widgets/app_loader.dart';
import '../controllers/accountant_dashboard_controller.dart';
import 'cash_flow_history_view.dart';

class AccountantHomeView extends GetView<AccountantDashboardController> {
  const AccountantHomeView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _green = AppColors.successGreen;
  static const _red = AppColors.errorRed;
  static const _redBg = Color(0xFFFEF2F2);

  IconData _getIconFromType(String iconType) {
    switch (iconType) {
      case 'OFFICE_SUPPLIES':
        return Icons.print_rounded;
      case 'CLIENT_MEETING':
      case 'FOOD':
        return Icons.restaurant_rounded;
      case 'TRAVEL':
        return Icons.directions_car_rounded;
      case 'SOFTWARE':
        return Icons.computer_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        final loading = controller.isDashboardLoading.value;
        final data = controller.dashboardData.value;

        return RefreshIndicator(
          color: _purple,
          onRefresh: controller.fetchDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (loading && data == null) ...[
                      SizedBox(height: 80.h),
                      const AppLoader(),
                    ] else if (controller.errorMessage.isNotEmpty &&
                        data == null) ...[
                      SizedBox(height: 40.h),
                      _buildErrorState(),
                    ] else if (data == null) ...[
                      SizedBox(height: 80.h),
                      Center(
                        child: Text(
                          'No data available',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: _slate500,
                          ),
                        ),
                      ),
                    ] else ...[
                      _buildCashCard(data.accountOverview.inHandCash,
                          data.accountOverview.inHandCashGrowth),
                      SizedBox(height: 14.h),
                      _buildBalanceRow(data.accountOverview.openBalance,
                          data.accountOverview.closingBalance),
                      SizedBox(height: 20.h),
                      _buildPendingBanner(
                          data.tasksSummary.pendingPaymentsCount),
                      SizedBox(height: 28.h),
                      _buildSectionHeader(
                        AppText.todayTransactions,
                        onSeeAll: () =>
                            Get.to(() => const CashFlowHistoryView()),
                      ),
                      SizedBox(height: 14.h),
                      if (data.todayTransactions.isEmpty)
                        _buildEmptyTransactions()
                      else
                        _buildTransactionList(data.todayTransactions),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        MediaQuery.of(context).padding.top + 16.h,
        24.w,
        28.h,
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
                SizedBox(height: 6.h),
                Text(
                  DateHelper.getFormattedDate(),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.ACCOUNTANT_NOTIFICATIONS),
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
    );
  }

  // ── Cash Card ────────────────────────────────────────────────────────
  Widget _buildCashCard(double inHandCash, String growth) {
    final isPositive = growth.startsWith('+');
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B55CE), Color(0xFF8B74E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.25),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                AppText.inHandCash,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${inHandCash.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 34.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: Colors.white,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '$growth ${AppText.vsYesterday}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Balance Row ──────────────────────────────────────────────────────
  Widget _buildBalanceRow(double open, double closing) {
    return Row(
      children: [
        Expanded(
          child: _balanceTile(
            label: AppText.openBalance,
            amount: '₹${open.toStringAsFixed(0)}',
            icon: Icons.lock_clock_rounded,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _balanceTile(
            label: AppText.closingBalance,
            amount: '₹${closing.toStringAsFixed(0)}',
            icon: Icons.lock_rounded,
          ),
        ),
      ],
    );
  }

  Widget _balanceTile({
    required String label,
    required String amount,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: _purple, size: 18.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: _slate500,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: _slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pending Banner ───────────────────────────────────────────────────
  Widget _buildPendingBanner(int count) {
    return GestureDetector(
      onTap: controller.navigateToPayments,
      child: Container(
        padding: EdgeInsets.all(18.w),
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
                Icons.payments_rounded,
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
                    AppText.pendingPayments,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _slate900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '$count ${AppText.paymentsNeedProcessing}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: _slate500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: _purple,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────────
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
              AppText.viewAll,
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

  // ── Transactions ─────────────────────────────────────────────────────
  Widget _buildTransactionList(List transactions) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final tx = transactions[i];
        final isExpense = tx.amount < 0;
        return Container(
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
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getIconFromType(tx.iconType),
                  color: _purple,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
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
                      tx.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: _slate500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                isExpense
                    ? '-₹${tx.amount.abs().toStringAsFixed(0)}'
                    : '+₹${tx.amount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: isExpense ? _red : _green,
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
          Icon(Icons.inbox_rounded, size: 48.sp, color: _slate300),
          SizedBox(height: 12.h),
          Text(
            'No transactions today',
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
              controller.errorMessage.value,
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}
