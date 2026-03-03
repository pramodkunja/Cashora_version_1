import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/accountant_payments_controller.dart';

class PendingPaymentsTab extends StatelessWidget {
  const PendingPaymentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountantPaymentsController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const SkeletonListView();
      }

      final expenses = controller.pendingExpenses;

      // Calculate Total Outstanding
      double totalAmount = 0;
      for (var item in expenses) {
        totalAmount += (item['amount'] as num?)?.toDouble() ?? 0.0;
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Total Outstanding Card
            Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          AppText.totalOutstanding,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSlate,
                            letterSpacing: 1.0,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primaryBlue,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.h1,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Across ${expenses.length} Pending Requests',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSlate,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // List of Pending Requests
            if (expenses.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: Text(
                    "No pending payments",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSlate,
                    ),
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
                  String name = 'Unknown User';
                  if (item['requestor'] != null) {
                    final req = item['requestor'];
                    name = "${req['first_name'] ?? ''} ${req['last_name'] ?? ''}"
                        .trim();
                    if (name.isEmpty) name = req['email'] ?? 'Unknown User';
                  }

                  return _buildRequestItem(
                    context,
                    id: item['request_id'] ?? '#REQ-${item['id']}',
                    date: _formatDate(item['created_at']),
                    name: name,
                    department: 'General',
                    category: item['category'] ?? 'Expense',
                    amount: '₹${((item['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                    data: item,
                  );
                },
              ),
          ],
        ),
      );
    });
  }


  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
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
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildRequestItem(
    BuildContext context, {
    required String id,
    required String date,
    required String name,
    required String department,
    required String category,
    required String amount,
    Map<String, dynamic>? data, // Added data param
  }) {
    return GestureDetector(
      onTap: () {
        if (data != null) {
          Get.toNamed(
            AppRoutes.ACCOUNTANT_PAYMENT_REQUEST_DETAILS,
            arguments: {'request': data},
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
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
                  // Make ID/Date flexible
                  child: Text(
                    '$id • $date',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSlate,
                      fontSize: 12.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            SizedBox(height: 8.h),
            Text(name, style: AppTextStyles.bodyLarge),
            SizedBox(height: 4.h),
            Text(
              '$department • $category',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSlate,
              ),
            ),
            SizedBox(height: 20.h),
            Divider(color: Theme.of(context).dividerColor),
            SizedBox(height: 16.h),
            Row(
              children: [
                if (data != null) ...[
                  // Status Tag based on request_type or status
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      (data['status']?.toString().toUpperCase() ?? 'APPROVED'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Payment Status Tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      (data['payment_status']
                              ?.toString()
                              .replaceAll('_', ' ')
                              .toUpperCase() ??
                          'PENDING'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warningOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    Text(
                      AppText.view,
                      style: AppTextStyles.buttonText.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
