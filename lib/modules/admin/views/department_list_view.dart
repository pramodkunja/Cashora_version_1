import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/department_controller.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';

class DepartmentListView extends GetView<DepartmentController> {
  const DepartmentListView({Key? key}) : super(key: key);

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
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.departments.isEmpty) {
                return const SkeletonListView();
              }
              if (controller.errorMessage.value.isNotEmpty &&
                  controller.departments.isEmpty) {
                return _buildErrorState();
              }
              if (controller.departments.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                color: _purple,
                onRefresh: controller.fetchDepartments,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                  itemCount: controller.departments.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) =>
                      _buildDeptCard(controller.departments[i]),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showCreateDialog,
        backgroundColor: _purple,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        icon: Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
        label: Text(
          'Add Department',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────
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
            'Departments',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Seed + toggle menu
          PopupMenuButton<String>(
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.more_horiz_rounded,
                  color: Colors.white, size: 18.sp),
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
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
                        color: _purple, size: 18.sp),
                    SizedBox(width: 10.w),
                    Text('Seed Defaults',
                        style: GoogleFonts.inter(fontSize: 14.sp)),
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
                        color: _slate500,
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        controller.showInactive.value
                            ? 'Hide Inactive'
                            : 'Show Inactive',
                        style: GoogleFonts.inter(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Department Card ──────────────────────────────────────────────────
  Widget _buildDeptCard(Map<String, dynamic> dept) {
    final name = dept['name']?.toString() ?? '';
    final code = dept['code']?.toString() ?? '';
    final isActive = dept['is_active'] ?? true;
    final id = dept['id'] is int
        ? dept['id'] as int
        : int.tryParse(dept['id'].toString()) ?? 0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: !isActive
            ? Border.all(color: AppColors.warningOrange.withOpacity(0.3))
            : null,
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
          // Icon
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: isActive
                  ? _purpleLight
                  : AppColors.warningOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.apartment_rounded,
              color: isActive ? _purple : AppColors.warningOrange,
              size: 22.sp,
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
                    if (!isActive) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.warningOrange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'INACTIVE',
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warningOrange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (code.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    code,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: _slate500,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: _slate300, size: 20.sp),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            onSelected: (v) {
              if (v == 'edit') controller.showEditDialog(dept);
              if (v == 'delete') controller.deleteDepartment(id, name);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 16.sp, color: _slate500),
                    SizedBox(width: 8.w),
                    Text('Edit', style: GoogleFonts.inter(fontSize: 14.sp)),
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
                      SizedBox(width: 8.w),
                      Text('Deactivate',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp, color: AppColors.errorRed)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty / Error ────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apartment_rounded, size: 56.sp, color: _slate300),
          SizedBox(height: 16.h),
          Text(
            'No departments yet',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _slate500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Use the menu to seed defaults\nor tap + to create one',
            style: GoogleFonts.inter(fontSize: 13.sp, color: _slate300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 40.sp, color: AppColors.errorRed),
            SizedBox(height: 12.h),
            Obx(
              () => Text(
                controller.errorMessage.value,
                style: GoogleFonts.inter(
                    fontSize: 13.sp, color: AppColors.errorRed),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: controller.fetchDepartments,
              icon: Icon(Icons.refresh_rounded, color: _purple, size: 18.sp),
              label: Text('Retry',
                  style: GoogleFonts.inter(
                      color: _purple, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
