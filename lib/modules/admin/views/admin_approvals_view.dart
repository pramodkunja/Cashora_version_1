import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../utils/request_mapper.dart'; // Added Import
import '../controllers/admin_approvals_controller.dart';
import 'widgets/admin_bottom_bar.dart';

class AdminApprovalsView extends GetView<AdminApprovalsController> {
  const AdminApprovalsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        // backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,

          centerTitle: true,
          title: Text(AppText.approvalsTitle, style: AppTextStyles.h3),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.textDark,
                size: 24.sp,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Colors.black26
                    : AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(
                  20.r,
                ), // Pill shape for tab bar container
              ),
              child: TabBar(
                padding: EdgeInsets.zero,
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                indicatorSize:
                    TabBarIndicatorSize.tab, // Ensures it fills the tab
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSlate,
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: AppText.tabPending),
                  Tab(text: AppText.tabApproved),
                  Tab(text: AppText.unpaid), // Replaces Rejected
                  Tab(text: AppText.clarification),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Obx(
              () => controller.isLoading.value
                  ? const SkeletonListView()
                  : _buildRequestList(controller.pendingRequests),
            ),
            Obx(
              () => controller.isLoading.value
                  ? const SkeletonListView()
                  : _buildRequestList(controller.approvedRequests),
            ),
            Obx(
              () => controller.isLoading.value
                  ? const SkeletonListView()
                  : _buildRequestList(controller.unpaidRequests),
            ),
            Obx(
              () => controller.isLoading.value
                  ? const SkeletonListView()
                  : _buildRequestList(controller.clarificationRequests),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          AppText.noRequests,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSlate),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(24.r),
      shrinkWrap: true,
      physics:
          const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works if added later
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = items[index];

        // Data Extraction
        final String title =
            item['title']?.toString() ??
            item['purpose']?.toString() ??
            AppText.unnamedRequest;
        final String user = RequestMapper.getUserName(item);
        final String amount = (item['amount'] is num)
            ? (item['amount'] as num).toStringAsFixed(2)
            : (item['amount']?.toString() ?? '0.00');
        final String department = RequestMapper.getDepartment(item);
        final String status = (item['status']?.toString() ?? 'Pending')
            .toUpperCase();

        String dateStr = RequestMapper.formatDate(
            item['date'] ?? item['created_at']);

        return GestureDetector(
          onTap: () => controller.navigateToDetails(item),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              children: [
                // TOP ROW: Icon + Title/Dept + Status/Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE), // Light Blue
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primaryBlue,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Title & Department
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            department,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSlate,
                              fontSize: 13.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Status & Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: RequestMapper.getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: RequestMapper.getStatusColor(status).withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: RequestMapper.getStatusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: AppColors.textSlate,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                Divider(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                SizedBox(height: 16.h),

                // BOTTOM ROW: User + Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Info
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                            child: Text(
                              RequestMapper.getInitials(user),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Requested by",
                                  style: TextStyle(
                                    color: AppColors.textSlate,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  user,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w), // Spacing between User and Amount

                    // Amount
                    Text(
                      '₹$amount',
                      style: AppTextStyles.h1.copyWith(fontSize: 20.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
