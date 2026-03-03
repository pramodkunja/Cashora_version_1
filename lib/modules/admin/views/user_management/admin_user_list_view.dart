import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/admin_user_controller.dart';
import '../widgets/admin_app_bar.dart';
import '../../../../utils/widgets/app_loader.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';

class AdminUserListView extends GetView<AdminUserController> {
  const AdminUserListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AdminAppBar(
        title: AppText.manageUsers,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: AppColors.textDark, size: 24.sp),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppText.searchUsersHint,
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                        ),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.search,
                          color: AppColors.textSlate,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.textSlate,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),

          // List Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Obx(
              () => Row(
                children: [
                  Text(
                    'ALL USERS (${controller.rxUsers.length})',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppText.exportList,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // User List
          Expanded(
            child: Obx(() {
              if (controller.isLoadingUsers.value) {
                return const SkeletonListView();
              }

              if (controller.rxUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64.sp,
                        color: AppColors.textLight,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No users found',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Users will appear here once added',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: controller.fetchUsers,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchUsers,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 8.h,
                  ),
                  itemCount: controller.rxUsers.length,
                  separatorBuilder: (c, i) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final user = controller.rxUsers[index];
                    return _buildUserCard(context, user);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 50.h,
        width: 150.w,
        child: FloatingActionButton.extended(
          onPressed: controller.addUser,
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          icon: Icon(Icons.person_add, color: Colors.white, size: 20.sp),
          label: Text(
            'Add User',
            style: AppTextStyles.buttonText.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    // Handle different field name variations
    String name =
        user['full_name'] ??
        user['name'] ??
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    if (name.isEmpty) name = 'Unknown User';

    String role = user['role'] ?? 'Requestor';
    String email = user['email'] ?? 'No email';

    Color badgeBg = const Color(0xFFF1F5F9);
    Color badgeText = AppColors.textSlate;

    // Verify active status based on various key possibilities
    final bool isActive = user['isActive'] ?? user['is_active'] ?? true;

    // Badge Status Logic
    if (!isActive) {
      badgeBg = const Color(0xFFFEE2E2); // Light Red
      badgeText = Colors.red;
    } else if (role.toLowerCase() == 'accountant') {
      badgeBg = const Color(0xFFE0F2FE); // Light Cyan
      badgeText = AppColors.infoBlue;
    } else if (role.toLowerCase() == 'approver') {
      badgeBg = const Color(0xFFF3E8FF); // Light Purple
      badgeText = const Color(0xFF9333EA); // Purple
    }

    return GestureDetector(
      onTap: () => controller.editUser(user),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: badgeBg,
              child: Text(
                name.isNotEmpty ? name.substring(0, 2).toUpperCase() : 'U',
                style: AppTextStyles.h3.copyWith(color: badgeText),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          !isActive
                              ? AppText.inactive.toUpperCase()
                              : role.toUpperCase(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: badgeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSlate,
                      fontSize: 13.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: AppColors.borderLight,
            ),
          ],
        ),
      ),
    );
  }
}
