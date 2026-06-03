import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/department_controller.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';

class DepartmentListView extends GetView<DepartmentController> {
  const DepartmentListView({super.key});

  // ── Palette (matches login/add-user) ──────────────────────────────────
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
                'Departments',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink900,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          _buildMenuButton(),
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

  Widget _buildMenuButton() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(Icons.more_horiz_rounded,
              color: _ink700, size: 20.sp),
        ),
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        onSelected: (v) {
          if (v == 'seed') controller.seedDefaults();
          if (v == 'toggle') {
            controller.toggleInactive(!controller.showInactive.value);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'seed',
            child: Row(
              children: [
                Icon(Icons.auto_fix_high_rounded,
                    color: AppColors.primary, size: 18.sp),
                SizedBox(width: 10.w),
                Text(
                  'Seed Defaults',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _ink900,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'toggle',
            child: Obx(
              () => Row(
                children: [
                  Icon(
                    controller.showInactive.value
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: _ink500,
                    size: 18.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    controller.showInactive.value
                        ? 'Hide Inactive'
                        : 'Show Inactive',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _ink900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                  child: Icon(Icons.apartment_rounded,
                      color: Colors.white, size: 22.sp),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage departments',
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
                      final n = controller.departments.length;
                      return Text(
                        '$n department${n == 1 ? "" : "s"} configured',
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

  // ─────────────────── LIST AREA (sheet) ───────────────────

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
        if (controller.isLoading.value && controller.departments.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: const SkeletonListView(),
          );
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.departments.isEmpty) {
          return _buildErrorState();
        }
        if (controller.departments.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchDepartments,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 110.h),
            itemCount: controller.departments.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) => _buildDeptCard(controller.departments[i]),
          ),
        );
      }),
    );
  }

  // ─────────────────── DEPARTMENT CARD ───────────────────

  Widget _buildDeptCard(Map<String, dynamic> dept) {
    final name = dept['name']?.toString() ?? '';
    final code = dept['code']?.toString() ?? '';
    final isActive = dept['is_active'] ?? true;
    final id = dept['id'] is int
        ? dept['id'] as int
        : int.tryParse(dept['id'].toString()) ?? 0;

    final Color iconBg =
        isActive ? AppColors.primary : AppColors.warningOrange;
    final Color borderColor = isActive
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.warningOrange.withValues(alpha: 0.30);

    return Container(
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
          // Gradient icon badge with subtle accent ring
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: iconBg.withValues(alpha: 0.20),
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
                    color: iconBg.withValues(alpha: 0.35),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.apartment_rounded,
                color: Colors.white,
                size: 22.sp,
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
                          color: AppColors.warningOrange.withValues(alpha: 0.14),
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
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (code.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          code,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    else
                      Text(
                        'No code',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: _ink300,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Actions menu
          _buildCardActionsMenu(dept, id, name, isActive),
        ],
      ),
    );
  }

  Widget _buildCardActionsMenu(
    Map<String, dynamic> dept,
    int id,
    String name,
    bool isActive,
  ) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: _bgB,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.more_vert_rounded, color: _ink500, size: 18.sp),
      ),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      onSelected: (v) {
        if (v == 'edit') controller.showEditDialog(dept);
        if (v == 'delete') controller.deleteDepartment(id, name);
        if (v == 'reactivate') controller.reactivateDepartment(id, name);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 16.sp, color: _ink700),
              SizedBox(width: 10.w),
              Text(
                'Edit',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _ink900,
                ),
              ),
            ],
          ),
        ),
        if (isActive)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.block_rounded,
                    size: 16.sp, color: AppColors.errorRed),
                SizedBox(width: 10.w),
                Text(
                  'Deactivate',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.errorRed,
                  ),
                ),
              ],
            ),
          )
        else
          PopupMenuItem(
            value: 'reactivate',
            child: Row(
              children: [
                Icon(Icons.refresh_rounded,
                    size: 16.sp, color: AppColors.successGreen),
                SizedBox(width: 10.w),
                Text(
                  'Reactivate',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─────────────────── EMPTY / ERROR ───────────────────

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
              child: Icon(Icons.apartment_rounded,
                  color: AppColors.primary, size: 44.sp),
            ),
            SizedBox(height: 18.h),
            Text(
              'No departments yet',
              style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: _ink900,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Use the menu to seed defaults\nor tap + to create one',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: _ink500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.errorRed.withValues(alpha: 0.10),
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 38.sp, color: AppColors.errorRed),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => Text(
                controller.errorMessage.value,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: _ink700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 18.h),
            Material(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: controller.fetchDepartments,
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
          onTap: controller.showCreateDialog,
          borderRadius: BorderRadius.circular(26.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'Add Department',
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
