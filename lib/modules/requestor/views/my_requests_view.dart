import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../routes/app_routes.dart';
import '../controllers/my_requests_controller.dart';
import '../../../../core/widgets/common_search_bar.dart';
import 'widgets/requestor_bottom_bar.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/app_colors.dart';
import '../../../utils/widgets/app_loader.dart';
import '../../../utils/widgets/skeletons/skeleton_loader.dart';

class MyRequestsView extends GetView<MyRequestsController> {
  const MyRequestsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppText.myRequests,
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor, // White/Dark Card Color
        surfaceTintColor: Colors.transparent, // Remove material 3 tint
        elevation: 0,
        actions: const [],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section (Search + Tabs)
            // Header Section (Search + Tabs)
            Container(
              clipBehavior: Clip
                  .hardEdge, // Prevent tabs from overlapping rounded corners
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  // Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    child: CommonSearchBar(
                      hintText: AppText.searchRequests,
                      onChanged: controller.searchRequests,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Scrollable Tab Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    child: Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTab(context, AppText.filterAll, 0),
                          SizedBox(width: 12.w),
                          _buildTab(context, AppText.filterPending, 1),
                          SizedBox(width: 12.w),
                          _buildTab(context, AppText.filterClarification, 5),
                          SizedBox(width: 12.w),
                          _buildTab(context, AppText.filterApproved, 2),
                          SizedBox(width: 12.w),
                          _buildTab(context, AppText.filterRejected, 3),
                          SizedBox(width: 12.w),
                          _buildTab(context, 'Unpaid', 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SkeletonListView();
                }

                if (controller.filteredRequests.isEmpty) {
                  return Center(
                    child: Text(
                      'No requests found',
                      style: TextStyle(color: AppColors.textSlate),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    16.w,
                    16.w,
                    100.h,
                  ), // Extra bottom padding for FAB
                  itemCount: controller.filteredRequests.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final req = controller.filteredRequests[index];
                    return _buildRequestCard(context, req);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.CREATE_REQUEST_TYPE),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, int index) {
    bool isSelected = controller.currentTab.value == index;
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.textSlate.withOpacity(0.2),
            width: 1.5,
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
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSlate,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> req) {
    Color statusColor;
    Color statusBg;

    final status = req['status']?.toString().toLowerCase() ?? 'pending';

    if (status == 'approved' || status == 'auto_approved') {
      statusColor = const Color(0xFF047857); // Emerald 700
      statusBg = const Color(0xFFD1FAE5); // Emerald 100
    } else if (status == 'pending') {
      statusColor = const Color(0xFFB45309); // Amber 700
      statusBg = const Color(0xFFFEF3C7); // Amber 100
    } else if (status == 'rejected') {
      statusColor = const Color(0xFFB91C1C); // Red 700
      statusBg = const Color(0xFFFEE2E2); // Red 100
    } else {
      statusColor = AppColors.textSlate;
      statusBg = AppColors.textSlate.withOpacity(0.1);
    }

    // Determine Status Text
    String statusText = status.toUpperCase();
    if (status == 'auto_approved') statusText = 'APPROVED';
    if (status == 'clarification_required') statusText = 'CLARIFICATION';

    // Icon + Color Logic
    IconData iconData = Icons.receipt_long_rounded;
    Color iconColor = AppColors.primaryBlue;
    Color iconBg = const Color(0xFFE0F2FE); // Blue 100

    final titleLower = (req['purpose'] ?? req['title'] ?? '')
        .toString()
        .toLowerCase();

    if (titleLower.contains('food') ||
        titleLower.contains('lunch') ||
        titleLower.contains('dinner')) {
      iconData = Icons.restaurant;
      iconColor = const Color(0xFF059669); // Emerald 600
      iconBg = const Color(0xFFECFDF5); // Emerald 50
    } else if (titleLower.contains('taxi') ||
        titleLower.contains('transport') ||
        titleLower.contains('uber')) {
      iconData = Icons.directions_car;
      iconColor = const Color(0xFFDC2626); // Red 600
      iconBg = const Color(0xFFFEF2F2); // Red 50
    } else if (titleLower.contains('flight') ||
        titleLower.contains('trip') ||
        titleLower.contains('travel')) {
      iconData = Icons.flight;
      iconColor = const Color(0xFF4F46E5); // Indigo 600
      iconBg = const Color(0xFFEEF2FF); // Indigo 50
    } else if (titleLower.contains('supplies') ||
        titleLower.contains('inventory')) {
      iconData = Icons.shopping_cart;
      iconColor = const Color(0xFFD97706); // Amber 600
      iconBg = const Color(0xFFFFFBEB); // Amber 50
    }

    // Date & Category
    final String date = req['date'] ?? 'No Date';
    final String category =
        req['category'] ??
        (titleLower.contains('food')
            ? 'Food'
            : titleLower.contains('travel')
            ? 'Travel'
            : titleLower.contains('supplies')
            ? 'Inventory'
            : 'General');

    return GestureDetector(
      onTap: () => controller.viewDetails(req),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req['purpose'] ?? req['title'] ?? 'Request',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "$date • $category",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${(req['amount'] as num?)?.toStringAsFixed(2) ?? "0.00"}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Rejection Note
            if (status == 'rejected') ...[
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2), // Red 50
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  req['rejection_reason'] ??
                      "Missing information or receipt attachment",
                  style: TextStyle(
                    color: const Color(0xFFEF4444),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
