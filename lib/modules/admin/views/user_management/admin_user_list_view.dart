import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/admin_user_controller.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';

class AdminUserListView extends GetView<AdminUserController> {
  const AdminUserListView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          // Search
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: TextField(
                style: GoogleFonts.inter(fontSize: 14.sp, color: _slate900),
                decoration: InputDecoration(
                  hintText: AppText.searchUsersHint,
                  hintStyle:
                      GoogleFonts.inter(fontSize: 14.sp, color: _slate300),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: _slate500, size: 20.sp),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Count bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Obx(
              () => Row(
                children: [
                  Text(
                    'ALL USERS (${controller.rxUsers.length})',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: _purple,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoadingUsers.value) {
                return const SkeletonListView();
              }
              if (controller.rxUsers.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                color: _purple,
                onRefresh: controller.fetchUsers,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 100.h),
                  itemCount: controller.rxUsers.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) =>
                      _buildUserCard(context, controller.rxUsers[i]),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addUser,
        backgroundColor: _purple,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        icon: Icon(Icons.person_add_rounded, color: Colors.white, size: 20.sp),
        label: Text(
          'Add User',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 12.h,
        20.w,
        20.h,
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
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            AppText.manageUsers,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${controller.rxUsers.length} users',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    String name =
        user['full_name'] ??
        user['name'] ??
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    if (name.isEmpty) name = 'Unknown User';

    final role = user['role']?.toString() ?? 'Requestor';
    final email = user['email']?.toString() ?? 'No email';
    final isActive = user['isActive'] ?? user['is_active'] ?? true;

    final dept = user['department'];
    String? deptName;
    if (dept is Map && dept['name'] != null) {
      deptName = dept['name'].toString();
    }

    // Role colors
    Color roleBg;
    Color roleColor;
    switch (role.toLowerCase()) {
      case 'accountant':
        roleBg = const Color(0xFFEFF6FF);
        roleColor = const Color(0xFF2563EB);
        break;
      case 'admin':
      case 'super_admin':
        roleBg = _purpleLight;
        roleColor = _purple;
        break;
      default:
        roleBg = const Color(0xFFF1F5F9);
        roleColor = _slate500;
    }

    if (!isActive) {
      roleBg = const Color(0xFFFEF2F2);
      roleColor = AppColors.errorRed;
    }

    return GestureDetector(
      onTap: () => controller.editUser(user),
      child: Container(
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
            // Avatar
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _purple.withOpacity(0.15),
                    _purple.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Text(
                  name.length >= 2
                      ? name.substring(0, 2).toUpperCase()
                      : name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _purple,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _slate900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: roleBg,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          !isActive
                              ? 'INACTIVE'
                              : role.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: roleColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: _slate500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (deptName != null) ...[
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(Icons.business_rounded,
                            size: 12.sp, color: _purple),
                        SizedBox(width: 4.w),
                        Text(
                          deptName,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: _purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _slate300, size: 22.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 56.sp, color: _slate300),
          SizedBox(height: 16.h),
          Text(
            'No users found',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _slate500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Users will appear here once added',
            style: GoogleFonts.inter(fontSize: 13.sp, color: _slate300),
          ),
          SizedBox(height: 20.h),
          TextButton.icon(
            onPressed: controller.fetchUsers,
            icon: Icon(Icons.refresh_rounded, color: _purple, size: 18.sp),
            label: Text('Retry',
                style: GoogleFonts.inter(color: _purple, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
