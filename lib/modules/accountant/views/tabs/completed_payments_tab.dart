import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/custom_search_bar.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/accountant_payments_controller.dart';

class CompletedPaymentsTab extends StatelessWidget {
  const CompletedPaymentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountantPaymentsController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const SkeletonListView();
      }

      final expenses = controller.completedExpenses;

      // Calculate Total Disbursed
      double totalDisbursed = 0;
      for (var item in expenses) {
        // API uses 'amount_paid' for completed payments
        totalDisbursed +=
            double.tryParse(
              item['amount_paid']?.toString() ??
                  item['amount']?.toString() ??
                  '0',
            ) ??
            0;
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Search Bar
            const CustomSearchBar(hintText: AppText.searchByIdOrName),
            SizedBox(height: 24.h),

            // Total Disbursed Card
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.totalDisbursed,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSlate,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '₹${totalDisbursed.toStringAsFixed(2)}',
                                  style: AppTextStyles.h1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Slate 100
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Icon(
                      Icons.attach_money_rounded,
                      size: 32.sp,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Filters Row (Keep static or make functional later if needed, user asked strictly for Tabs)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Removed filters as per revert instructions/simplicity but kept method if needed.
                  // Actually user asked to revert filters for "rejected/cancelled".
                  // This is "Completed" tab, so filters are harmless, but let's keep them.
                  _buildFilterChip(context, 'Date Range'),
                  SizedBox(width: 8.w),
                  _buildFilterChip(context, 'Category'),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Completed',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.textLight,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // List Items
            if (expenses.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text(
                  "No completed payments",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSlate,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final item = expenses[index];

                  // Extract Amount
                  final amountVal =
                      double.tryParse(
                        item['amount_paid']?.toString() ??
                            item['amount']?.toString() ??
                            '0',
                      ) ??
                      0.0;

                  // Extract Date
                  final dateStr =
                      item['processed_at'] ??
                      item['created_at'] ??
                      item['updated_at'];
                  String formattedDate = '';
                  if (dateStr != null) {
                    try {
                      final dt = DateTime.parse(dateStr);
                      const months = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec',
                      ];
                      formattedDate =
                          '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
                    } catch (_) {
                      formattedDate = dateStr.toString().split('T')[0];
                    }
                  }

                  // Extract Name / Title
                  // 'payments' list items often lack requestor/payee details directly.
                  // So we use request_id or payment_id as the main identifier if name is missing.
                  String title = 'Unknown User';
                  if (item['requestor'] != null && item['requestor'] is Map) {
                    final req = item['requestor'];
                    title =
                        "${req['first_name'] ?? ''} ${req['last_name'] ?? ''}"
                            .trim();
                    if (title.isEmpty) title = req['email'] ?? 'Unknown User';
                  } else if (item['payee_name'] != null) {
                    title = item['payee_name'];
                  } else {
                    // Fallback: Use Request ID as title
                    title = item['request_id'] ?? 'Payment #${item['id']}';
                  }

                  // Extract Subtitle / Details
                  String subtitle =
                      item['payment_source'] ?? item['category'] ?? '';
                  if (subtitle.isEmpty) {
                    // If no category, show the Payment ID
                    subtitle = item['payment_id'] ?? 'ID: ${item['id']}';
                  }

                  return _buildCompletedItem(
                    context,
                    payment: item,
                    id: (item['payment_id'] ?? item['id']?.toString() ?? '')
                        .toString()
                        .toUpperCase(),
                    date: formattedDate,
                    name: title,
                    details: subtitle,
                    amount: '₹${amountVal.toStringAsFixed(2)}',
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSlate),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16.sp,
            color: AppColors.textSlate,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedItem(
    BuildContext context, {
    required Map<String, dynamic> payment,
    required String id,
    required String date,
    required String name,
    required String details,
    required String amount,
  }) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.ACCOUNTANT_PAYMENT_COMPLETED_DETAILS,
          arguments: payment,
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  // Allow ID to shrink/truncate
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      id,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSlate,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    AppText.completedSC,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        details,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSlate,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  amount,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(color: Theme.of(context).dividerColor),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14.sp,
                        color: AppColors.textLight,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          date,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: AppColors.textDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
