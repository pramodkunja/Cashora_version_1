import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../controllers/admin_dashboard_controller.dart';

/// Single elegant white card showing the org summary on the admin
/// dashboard — total departments, active departments, unassigned users.
class AdminDashboardOrgCard extends StatelessWidget {
  final AdminDashboardController controller;

  static const _slate600 = Color(0xFF475569);
  static const _blue = Color(0xFF0EA5E9);
  static const _blueBg = Color(0xFFE0F2FE);

  const AdminDashboardOrgCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          children: [
            _OrgRow(
              icon: Icons.business_rounded,
              accent: AppColors.primary,
              accentBg: AppColors.purpleSurface,
              label: 'Total departments',
              value: controller.totalDepartments.value.toString(),
              showDivider: true,
              onTap: () => Get.toNamed(AppRoutes.ADMIN_DEPARTMENTS),
            ),
            _OrgRow(
              icon: Icons.check_circle_outline_rounded,
              accent: AppColors.successGreen,
              accentBg: AppColors.mintBg,
              label: 'Active departments',
              value: controller.activeDepartments.value.toString(),
              showDivider: true,
              onTap: () => Get.toNamed(AppRoutes.ADMIN_DEPARTMENTS),
            ),
            _OrgRow(
              icon: Icons.person_outline_rounded,
              accent: _blue,
              accentBg: _blueBg,
              label: 'Unassigned users',
              value: controller.unassignedUsers.value.toString(),
              showDivider: false,
              onTap: () => Get.toNamed(AppRoutes.ADMIN_USER_LIST),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrgRow extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final Color accentBg;
  final String label;
  final String value;
  final bool showDivider;
  final VoidCallback? onTap;

  const _OrgRow({
    required this.icon,
    required this.accent,
    required this.accentBg,
    required this.label,
    required this.value,
    required this.showDivider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accent, size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AdminDashboardOrgCard._slate600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.2,
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.slate300, size: 18.sp),
          ],
        ],
      ),
    );

    final content = onTap == null
        ? row
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10.r),
              splashColor: accent.withValues(alpha: 0.08),
              highlightColor: accent.withValues(alpha: 0.04),
              child: row,
            ),
          );

    return Column(
      children: [
        content,
        if (showDivider) Container(height: 1, color: AppColors.slate100),
      ],
    );
  }
}
