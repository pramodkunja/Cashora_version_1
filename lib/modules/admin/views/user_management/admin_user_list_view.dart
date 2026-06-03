import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/admin_user_controller.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';

class AdminUserListView extends GetView<AdminUserController> {
  const AdminUserListView({super.key});

  // ── Palette (matches departments + add-user) ──────────────────────────
  static const Color _bgA = Color(0xFFF0E9FF);
  static const Color _bgB = Color(0xFFF8F7FF);
  static const Color _bgC = Color(0xFFEEF2FF);

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink300 = Color(0xFFCBD5E1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgB,
      body: Stack(
        children: [
          _backgroundLayer(),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                _buildHeroBlock(),
                Expanded(child: _buildListArea()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildGradientFab(),
    );
  }

  // ─────────────────── BACKGROUND ───────────────────

  Widget _backgroundLayer() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgA, _bgB, _bgC],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -90.h,
          right: -70.w,
          child: _bloom(280.w, AppColors.primary, 0.18),
        ),
        Positioned(
          top: 40.h,
          left: -60.w,
          child: _bloom(200.w, AppColors.primaryLight, 0.24),
        ),
      ],
    );
  }

  Widget _bloom(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  // ─────────────────── TOP BAR ───────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          _circleIconButton(Icons.arrow_back_rounded, () => Get.back()),
          Expanded(
            child: Center(
              child: Text(
                AppText.manageUsers,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink900,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          _circleIconButton(Icons.refresh_rounded, controller.fetchUsers),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(icon, color: _ink700, size: 20.sp),
        ),
      ),
    );
  }

  // ─────────────────── HERO BLOCK ───────────────────

  Widget _buildHeroBlock() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.20),
                    width: 1.4,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14.r,
                      ),
                    ],
                  ),
                  child: Icon(Icons.groups_rounded,
                      color: Colors.white, size: 22.sp),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage team',
                      style: GoogleFonts.outfit(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: _ink900,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Obx(() {
                      final n = controller.rxUsers.length;
                      return Text(
                        '$n user${n == 1 ? "" : "s"} in your organization',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: _ink500,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────── LIST AREA (white sheet) ───────────────────

  Widget _buildListArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36.r),
          topRight: Radius.circular(36.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 24.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoadingUsers.value) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: const SkeletonListView(),
          );
        }
        if (controller.rxUsers.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchUsers,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
                  child: _buildSearchBar(),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 6.h),
                sliver: SliverToBoxAdapter(
                  child: Obx(() => Text(
                        'ALL USERS · ${controller.rxUsers.length}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      )),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 110.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildUserCard(controller.rxUsers[i]),
                    ),
                    childCount: controller.rxUsers.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────── SEARCH BAR ───────────────────

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _bgB,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
      ),
      child: TextField(
        style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: AppText.searchUsersHint,
          hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: _ink300),
          prefixIcon:
              Icon(Icons.search_rounded, color: AppColors.primary, size: 20.sp),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  // ─────────────────── USER CARD ───────────────────

  Widget _buildUserCard(Map<String, dynamic> user) {
    String name = user['full_name'] ??
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
    Color rolePillBg;
    Color rolePillFg;
    switch (role.toLowerCase()) {
      case 'accountant':
        rolePillBg = const Color(0xFFEFF6FF);
        rolePillFg = const Color(0xFF2563EB);
        break;
      case 'admin':
      case 'super_admin':
        rolePillBg = AppColors.primary.withValues(alpha: 0.10);
        rolePillFg = AppColors.primary;
        break;
      default:
        rolePillBg = const Color(0xFFF1F5F9);
        rolePillFg = _ink500;
    }

    final Color avatarAccent =
        isActive ? AppColors.primary : AppColors.warningOrange;
    final Color borderColor = isActive
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.warningOrange.withValues(alpha: 0.30);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: () => controller.editUser(user),
        borderRadius: BorderRadius.circular(20.r),
        splashColor: AppColors.primary.withValues(alpha: 0.06),
        highlightColor: AppColors.primary.withValues(alpha: 0.03),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 18.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gradient avatar badge with accent ring
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: avatarAccent.withValues(alpha: 0.20),
                    width: 1.2,
                  ),
                ),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isActive
                          ? [AppColors.primary, AppColors.primaryLight]
                          : [
                              AppColors.warningOrange,
                              AppColors.warningOrange.withValues(alpha: 0.75),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: avatarAccent.withValues(alpha: 0.35),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.length >= 2
                          ? name.substring(0, 2).toUpperCase()
                          : name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: _ink900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isActive) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.warningOrange.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'INACTIVE',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warningOrange,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: _ink500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: rolePillBg,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: rolePillFg,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        if (deptName != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.business_rounded,
                                  size: 11.sp,
                                  color: AppColors.primary),
                              SizedBox(width: 3.w),
                              Text(
                                deptName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: _bgB,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    color: _ink500, size: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────── EMPTY STATE ───────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
              child: Icon(Icons.people_outline_rounded,
                  color: AppColors.primary, size: 44.sp),
            ),
            SizedBox(height: 18.h),
            Text(
              'No users found',
              style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: _ink900,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Users will appear here once added',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: _ink500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.h),
            Material(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: controller.fetchUsers,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 18.w, vertical: 10.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: AppColors.primary, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── GRADIENT FAB ───────────────────

  Widget _buildGradientFab() {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.addUser,
          borderRadius: BorderRadius.circular(26.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_rounded,
                    color: Colors.white, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'Add User',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
