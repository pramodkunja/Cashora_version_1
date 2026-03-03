import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../controllers/cash_flow_history_controller.dart';
import '../../../../utils/widgets/custom_search_bar.dart';

class CashFlowHistoryView extends GetView<CashFlowHistoryController> {
  const CashFlowHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensuring controller is available if not via binding locally for now
    // In real app, bind in AppPages
    Get.put(CashFlowHistoryController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textDark,
            size: 24.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppText.cashFlowHistory,
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle:
            false, // Left aligned as per typical Android/Flutter default or image appearance? Image shows center/left. Default is fine.
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: [
                    _buildFilterChip(context, AppText.thisMonthFilter, 0),
                    SizedBox(width: 12.w),
                    _buildFilterChip(context, AppText.last3Months, 1),
                    SizedBox(width: 12.w),
                    _buildFilterChip(context, AppText.custom, 2),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Total Summary Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Column(
                  children: [
                    // Top Colored Line
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4.h,
                            color: AppColors.successGreen,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 4.h,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.successGreen
                                            .withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 14.sp,
                                        color: AppColors.successGreen,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      AppText.totalIn,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSlate,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '₹15,250',
                                    style: AppTextStyles.h1.copyWith(
                                      fontSize: 28.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1.w,
                            height: 50.h,
                            color: Theme.of(context).dividerColor,
                          ),
                          SizedBox(width: 24.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorRed.withOpacity(
                                          0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 14.sp,
                                        color: AppColors.errorRed,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      AppText.totalOut,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSlate,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '₹4,120',
                                    style: AppTextStyles.h1.copyWith(
                                      fontSize: 28.sp,
                                    ),
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
              ),
            ),

            SizedBox(height: 32.h),
            Text(AppText.detailedTransactions, style: AppTextStyles.h3),
            SizedBox(height: 16.h),

            // List Items
            _buildHistoryItem(
              context,
              title: AppText.weeklyReplenishment,
              subtitle: 'Oct 24 • Admin',
              amount: '+₹2,000.00',
              icon: Icons.account_balance_wallet_rounded,
              isCashIn: true,
              iconBg: const Color(0xFFDCFCE7),
              iconColor: AppColors.successGreen,
            ),
            SizedBox(height: 16.h),
            _buildHistoryItem(
              context,
              title: AppText.officeSupplies,
              subtitle: 'Oct 23 • Staples',
              amount: '-₹45.00',
              icon: Icons.print_rounded,
              isCashIn: false,
              iconBg: const Color(0xFFF1F5F9), // Slate 100
              iconColor: AppColors.textSlate,
            ),
            SizedBox(height: 16.h),
            _buildHistoryItem(
              context,
              title: AppText.transportToClient,
              subtitle: 'Oct 22 • Uber',
              amount: '-₹32.50',
              icon: Icons.directions_car_rounded,
              isCashIn: false,
              iconBg: const Color(0xFFF1F5F9),
              iconColor: AppColors.textSlate,
            ),
            SizedBox(height: 16.h),
            _buildHistoryItem(
              context,
              title: AppText.refreshments,
              subtitle: 'Oct 21 • Starbucks',
              amount: '-₹18.00',
              icon: Icons.coffee_rounded,
              isCashIn: false,
              iconBg: const Color(0xFFF1F5F9),
              iconColor: AppColors.textSlate,
            ),
            SizedBox(height: 16.h),
            _buildHistoryItem(
              context,
              title: AppText.vendorRefund,
              subtitle: 'Oct 20 • Amazon',
              amount: '+₹125.00',
              icon: Icons.undo_rounded,
              isCashIn: true,
              iconBg: const Color(0xFFDCFCE7),
              iconColor: AppColors.successGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, int index) {
    bool isSelected = controller.selectedFilter.value == index;
    return GestureDetector(
      onTap: () => controller.changeFilter(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : Colors
                      .transparent, // Border check? Image shows clean white for unselected
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSlate,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    required bool isCashIn,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: isCashIn
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        isCashIn ? AppText.cashIn : AppText.cashOut,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: isCashIn
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
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
          Text(
            amount,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: isCashIn
                  ? AppColors.successGreen
                  : AppColors
                        .textDark, // Image shows black for debit? No, looks like black.
            ),
          ),
        ],
      ),
    );
  }
}
