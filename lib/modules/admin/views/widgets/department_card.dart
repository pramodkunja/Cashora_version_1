import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../controllers/department_controller.dart';

/// One row in the department list — gradient icon disc, name + code +
/// optional INACTIVE badge, three-dot actions menu (edit / deactivate
/// / reactivate).
class DepartmentCard extends StatelessWidget {
  final Map<String, dynamic> dept;
  final DepartmentController controller;

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink300 = Color(0xFFCBD5E1);

  const DepartmentCard({
    super.key,
    required this.dept,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final name = dept['name']?.toString() ?? '';
    final code = dept['code']?.toString() ?? '';
    final isActive = dept['is_active'] ?? true;
    final id = dept['id'] is int
        ? dept['id'] as int
        : int.tryParse(dept['id'].toString()) ?? 0;

    final Color iconBg =
        isActive ? AppColors.primary : AppColors.warningOrange;
    final Color borderColor = isActive
        ? AppColors.primary.withOpacity(0.08)
        : AppColors.warningOrange.withOpacity(0.30);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _IconBadge(isActive: isActive, iconBg: iconBg),
          SizedBox(width: 14.w),
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
                      const _InactiveTag(),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                code.isNotEmpty
                    ? _CodeTag(code: code)
                    : Text(
                        'No code',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: _ink300,
                        ),
                      ),
              ],
            ),
          ),
          DepartmentCardActionsMenu(
            dept: dept,
            id: id,
            name: name,
            isActive: isActive,
            controller: controller,
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final bool isActive;
  final Color iconBg;

  const _IconBadge({required this.isActive, required this.iconBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: iconBg.withOpacity(0.20), width: 1.2),
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
                    AppColors.warningOrange.withOpacity(0.75),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: iconBg.withOpacity(0.35),
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
    );
  }
}

class _InactiveTag extends StatelessWidget {
  const _InactiveTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withOpacity(0.14),
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
    );
  }
}

class _CodeTag extends StatelessWidget {
  final String code;
  const _CodeTag({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
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
    );
  }
}

/// Three-dot kebab on each department row. Renders Edit + Deactivate
/// (when active) / Reactivate (when inactive) menu items.
class DepartmentCardActionsMenu extends StatelessWidget {
  final Map<String, dynamic> dept;
  final int id;
  final String name;
  final bool isActive;
  final DepartmentController controller;

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);

  const DepartmentCardActionsMenu({
    super.key,
    required this.dept,
    required this.id,
    required this.name,
    required this.isActive,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
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
                Icon(
                  Icons.block_rounded,
                  size: 16.sp,
                  color: AppColors.errorRed,
                ),
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
                Icon(
                  Icons.refresh_rounded,
                  size: 16.sp,
                  color: AppColors.successGreen,
                ),
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
}
