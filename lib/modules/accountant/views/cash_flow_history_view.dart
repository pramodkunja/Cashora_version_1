import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../controllers/cash_flow_history_controller.dart';
import '../../../../utils/widgets/app_loader.dart';
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
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const AppLoader();
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                controller.errorMessage.value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.errorRed,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetch,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, AppText.thisMonthFilter, 0),
                      SizedBox(width: 12.w),
                      _buildFilterChip(context, AppText.last3Months, 1),
                      SizedBox(width: 12.w),
                      _buildFilterChip(context, AppText.custom, 2),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Summary Card — backend only returns totalExpenses (Cash Out).
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.monthYear.value.isNotEmpty) ...[
                        Text(
                          controller.monthYear.value,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSlate,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_downward_rounded,
                              size: 16.sp,
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
                          '₹${controller.totalExpenses.value.toStringAsFixed(2)}',
                          style: AppTextStyles.h1.copyWith(fontSize: 28.sp),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),
                Text(AppText.detailedTransactions, style: AppTextStyles.h3),
                SizedBox(height: 16.h),

                if (controller.transactions.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Center(
                      child: Text(
                        'No transactions',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                        ),
                      ),
                    ),
                  )
                else
                  ...controller.transactions.map((tx) {
                    final title = (tx['category'] ?? 'Expense').toString();
                    final date = (tx['date'] ?? '').toString();
                    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildHistoryItem(
                        context,
                        title: title,
                        subtitle: date,
                        amount: '-₹${amount.toStringAsFixed(2)}',
                        icon: Icons.receipt_long_rounded,
                        isCashIn: false,
                        iconBg: const Color(0xFFF1F5F9),
                        iconColor: AppColors.textSlate,
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      }),
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
