import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../utils/widgets/buttons/secondary_button.dart';
import '../controllers/requestor_controller.dart';
import '../controllers/my_requests_controller.dart';
import 'widgets/requestor_bottom_bar.dart';
import '../../admin/views/widgets/welcome_message.dart';
import '../../../../utils/date_helper.dart';

class RequestorDashboardView extends GetView<RequestorController> {
  const RequestorDashboardView({Key? key}) : super(key: key);

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
                      Flexible(
                        child: Text(AppText.helloUser, style: AppTextStyles.h3),
                      ),
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
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.ADMIN_NOTIFICATIONS),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 0.0,
          bottom: 40.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeMessage(
              name: controller.shortName,
              showWelcome: controller.showWelcome,
            ),
            SizedBox(height: 24.h),
            _buildActionButtons(),
            SizedBox(height: 24.h),
            _buildMonthlyExpenseCard(context),
            SizedBox(height: 24.h),
            _buildPendingRequestsCard(context),
            SizedBox(height: 24.h),
            Text(
              AppText.recentRequests,
              style: AppTextStyles.h3, // Standardized style
            ),
            SizedBox(height: 16.h),
            _buildRecentRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: AppText.newRequest,
            onPressed: () => Get.toNamed(AppRoutes.CREATE_REQUEST_TYPE),
            icon: Icon(Icons.add_circle, size: 20.sp, color: Colors.white),
          ),
        ),
        SizedBox(width: 16.w),
        // Example for future: SecondaryButton usage
        Expanded(
          child: SecondaryButton(
            text: AppText.uploadBill,
            onPressed: () {
              // Future implementation
            },
            icon: Icon(
              Icons.upload_file,
              size: 20.sp,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyExpenseCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.monthlyExpense,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTextStyles.bodyMedium.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppText.thisMonthsSpending,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹350.50',
                style: AppTextStyles.h1.copyWith(fontSize: 32.sp),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Text(
                  '/ ₹1000 ${AppText.limit}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: 0.35, // 350/1000
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 20.h),
          InkWell(
            onTap: () => Get.toNamed(AppRoutes.MONTHLY_SPENT),
            child: Text(
              AppText.viewDetails,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<MyRequestsController>().changeTab(1);
        controller.changeTab(1);
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.infoBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Icon(
                Icons.pending_actions,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.pendingApprovals,
                    style: AppTextStyles.bodyLarge,
                  ),
                  SizedBox(height: 4.h),
                  Obx(
                    () => Text(
                      '${controller.pendingCount.value} ${AppText.requestsWaiting}', // Dynamic count
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            SecondaryButton(
              text: 'View All',
              onPressed: () {
                Get.find<MyRequestsController>().changeTab(1);
                controller.changeTab(1);
              },
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequestsList() {
    return Obx(() {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentRequests.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final item = controller.recentRequests[index];
          return GestureDetector(
            onTap: () =>
                Get.toNamed(AppRoutes.REQUEST_DETAILS_READ, arguments: item),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: item['color'] as Color, // e.g., Colors.blue[100]
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['iconColor'] as Color,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: AppTextStyles.bodyLarge,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item['date'] as String,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${(item['amount'] as double).toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            item['status'] as String,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          item['status'] as String,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(item['status'] as String),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Color _getStatusColor(String status) {
    if (status == 'Approved') return AppColors.success;
    if (status == 'Rejected') return AppColors.error;
    return AppColors.warning;
  }
}
