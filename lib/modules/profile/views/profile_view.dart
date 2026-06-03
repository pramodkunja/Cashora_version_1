import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/skeletons/page_skeletons.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../../admin/views/widgets/admin_bottom_bar.dart';
import '../../requestor/views/widgets/requestor_bottom_bar.dart';
import '../../../../core/services/auth_service.dart';

class ProfileView extends GetView<ProfileController> {
  final bool isTab;
  const ProfileView({super.key, this.isTab = false});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      bottomNavigationBar: isTab ? null : _buildBottomBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ProfilePageSkeleton();
        }
        return CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context)),
            // ── Body ────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Info section
                  _buildSectionLabel('PERSONAL INFO'),
                  SizedBox(height: 10.h),
                  _buildInfoCard(context),
                  SizedBox(height: 20.h),

                  // Admin actions
                  if (_isAdmin) ...[
                    _buildSectionLabel('ADMIN'),
                    SizedBox(height: 10.h),
                    _buildAdminCard(),
                    SizedBox(height: 20.h),
                  ],

                  // General actions
                  _buildSectionLabel('SETTINGS'),
                  SizedBox(height: 10.h),
                  _buildSettingsCard(),

                  SizedBox(height: 36.h),
                  _buildLogoutButton(),
                  SizedBox(height: 20.h),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  bool get _isAdmin => ['admin', 'super_admin']
      .contains(Get.find<AuthService>().currentUser.value?.role.toLowerCase());

  // ════════════════════════════════════════════════════════════════════════
  // HEADER — purple gradient with avatar + name + role badge
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        MediaQuery.of(context).padding.top + 12.h,
        24.w,
        32.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          // Top row — back + edit
          Row(
            children: [
              if (!isTab)
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20.sp),
                  ),
                )
              else
                SizedBox(width: 36.w),
              const Spacer(),
              Text(
                AppText.myProfile,
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: controller.editProfile,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    AppText.edit,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Avatar
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 2.5.w),
            ),
            child: CircleAvatar(
              radius: 42.r,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Obx(
                () => Text(
                  _initials(controller.rxName.value),
                  style: GoogleFonts.inter(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Name
          Obx(
            () => Text(
              controller.rxName.value,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 6.h),

          // Role badge + email
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    controller.rxRole.value.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    controller.rxEmail.value,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // INFO CARD
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildInfoCard(BuildContext context) {
    return Obx(
      () => _card([
        _infoRow(Icons.business_rounded, 'Organization',
            controller.rxOrgName.value),
        _infoRow(Icons.qr_code_rounded, 'Org Code',
            controller.rxOrgCode.value),
        _infoRow(Icons.phone_rounded, AppText.phone, controller.rxPhone.value),
        _infoRow(Icons.badge_rounded, AppText.role, controller.rxRole.value),
        if (controller.rxDepartmentName.value.isNotEmpty)
          _infoRow(Icons.business_rounded, 'Department',
              controller.rxDepartmentName.value),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // ADMIN CARD
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildAdminCard() {
    return _card([
      _actionRow(Icons.people_outline_rounded, AppText.manageUsers,
          controller.navigateToManageUsers,
          accent: AppColors.successGreen, accentBg: AppColors.mintBg),
      _actionRow(Icons.business_rounded, 'Manage Departments',
          () => Get.toNamed(AppRoutes.ADMIN_DEPARTMENTS)),
      _actionRow(Icons.tune_rounded, 'Set Approval Limits',
          () => Get.toNamed(AppRoutes.ADMIN_SET_LIMITS)),
    ]);
  }

  // ════════════════════════════════════════════════════════════════════════
  // SETTINGS CARD
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSettingsCard() {
    return _card([
      _actionRow(Icons.lock_outline_rounded, AppText.changePassword,
          controller.navigateToChangePassword),
      _actionRow(Icons.settings_rounded, AppText.appSettings,
          controller.navigateToSettings),
    ]);
  }

  // ════════════════════════════════════════════════════════════════════════
  // LOGOUT
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: controller.logout,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              AppText.logOut,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.errorRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // REUSABLE BUILDERS
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSlate,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 0, indent: 62.w, color: const Color(0xFFF1F5F9)),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: AppColors.purpleSurface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSlate,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value.isEmpty ? '-' : value,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(IconData icon, String title, VoidCallback onTap,
      {Color? accent, Color? accentBg}) {
    final color = accent ?? AppColors.primary;
    final bg = accentBg ?? AppColors.purpleSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.slate300, size: 22.sp),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildBottomBar() {
    final userRole =
        Get.find<AuthService>().currentUser.value?.role.toLowerCase();

    if (userRole == 'admin' || userRole == 'super_admin') {
      return AdminBottomBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Get.offNamed(AppRoutes.ADMIN_DASHBOARD);
          if (index == 1) Get.offNamed(AppRoutes.ADMIN_APPROVALS);
          if (index == 2) Get.offNamed(AppRoutes.ADMIN_HISTORY);
        },
      );
    } else {
      return RequestorBottomBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Get.offNamed(AppRoutes.REQUESTOR);
          if (index == 1) Get.offNamed(AppRoutes.MY_REQUESTS);
        },
      );
    }
  }
}
