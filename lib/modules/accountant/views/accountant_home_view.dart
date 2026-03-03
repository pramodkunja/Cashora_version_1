import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../controllers/accountant_dashboard_controller.dart';
import 'cash_flow_history_view.dart';
import '../../admin/views/widgets/welcome_message.dart';
import '../../../../utils/date_helper.dart';

class AccountantHomeView extends GetView<AccountantDashboardController> {
  const AccountantHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text('Hello,', style: AppTextStyles.h3)),
                      SizedBox(width: 4.w),
                      // Dynamic user greeting
                      Flexible(
                        child: Obx(
                          () => Text(
                            '${controller.shortName}!',
                            style: AppTextStyles.h3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateHelper.getFormattedDate(),
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.ACCOUNTANT_NOTIFICATIONS),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeMessage(
              name: controller.shortName,
              showWelcome: controller.showWelcome,
            ),
            SizedBox(height: 24.h),
            // In-Hand Cash Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        AppText.inHandCash,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₹4,250.00',
                      style: AppTextStyles.h1.copyWith(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            '+2.4% ${AppText.vsYesterday}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Balance Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildBalanceCard(
                    context,
                    title: AppText.openBalance,
                    amount: '₹5,000.00',
                    icon: Icons.lock_clock_outlined,
                    iconBg: Theme.of(context).primaryColor.withOpacity(0.1),
                    iconColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildBalanceCard(
                    context,
                    title: AppText.closingBalance,
                    amount: '₹4,250.00',
                    icon: Icons.lock_outline,
                    iconBg: Theme.of(context).primaryColor.withOpacity(0.1),
                    iconColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Amount In/Out Row
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTransactionSummary(
                      icon: Icons.south_west_rounded,
                      iconBg: AppColors.successGreen.withOpacity(0.15),
                      iconColor: AppColors.successGreen,
                      label: AppText.amountIn,
                      amount: '+₹500.00',
                    ),
                  ),
                  Container(
                    height: 40.h,
                    width: 1.w,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(
                    child: _buildTransactionSummary(
                      icon: Icons.north_east_rounded,
                      iconBg: AppColors.errorRed.withOpacity(0.15),
                      iconColor: AppColors.errorRed,
                      label: AppText.amountOut,
                      amount: '-₹1,250.00',
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Pending Payments Card
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.pendingPayments,
                              style: AppTextStyles.h3,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '5 ${AppText.paymentsNeedProcessing}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.payments_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller
                          .navigateToPayments(), // Use navigation method to trigger fetch
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppText.processPayments,
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.arrow_forward_rounded, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Today's Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    AppText.todayTransactions,
                    style: AppTextStyles.h3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Get.to(() => const CashFlowHistoryView()), // Still pushed
                  child: Text(
                    AppText.viewAll,
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTransactionItem(
              context,
              title: 'Office Supplies',
              subtitle: 'Staples • 10:45 AM',
              amount: '-₹45.00',
              icon: Icons.print_rounded,
            ),
            SizedBox(height: 16.h),
            _buildTransactionItem(
              context,
              title: 'Client Lunch',
              subtitle: 'Panera • 12:30 PM',
              amount: '-₹85.00',
              icon: Icons.restaurant_rounded,
            ),
            SizedBox(height: 16.h),
            _buildTransactionItem(
              context,
              title: 'Travel Expense',
              subtitle: 'Uber • 2:15 PM',
              amount: '-₹22.50',
              icon: Icons.directions_car_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context, {
    required String title,
    required String amount,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(amount, style: AppTextStyles.h3),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String amount,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: iconColor, size: 16.sp),
        ),
        SizedBox(height: 8.h),
        Text(label, style: AppTextStyles.bodySmall),
        SizedBox(height: 4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color:
                  Theme.of(context).iconTheme.color?.withOpacity(0.5) ??
                  AppColors.textSlate,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge,
                  overflow: TextOverflow.ellipsis, // Prevent Title Overflow
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSlate,
                  ),
                  overflow: TextOverflow.ellipsis, // Prevent Subtitle Overflow
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            amount,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
