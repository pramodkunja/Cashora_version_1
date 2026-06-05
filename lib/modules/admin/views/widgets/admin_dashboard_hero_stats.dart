import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/formatters/currency_formatter.dart';
import '../../controllers/admin_approvals_controller.dart';
import '../../controllers/admin_dashboard_controller.dart';

/// Hero stat card for the admin dashboard — two stat tiles
/// (Pending + Clarification) on top, full-width "Approved" gradient
/// strip on the bottom.
///
/// Tapping a stat tile pre-selects the matching sub-tab on the
/// approvals controller and switches the bottom-nav to Approvals.
class AdminDashboardHeroStats extends StatelessWidget {
  final AdminDashboardController controller;

  const AdminDashboardHeroStats({super.key, required this.controller});

  void _openApprovalsTab(int subTabIndex) {
    if (Get.isRegistered<AdminApprovalsController>()) {
      Get.find<AdminApprovalsController>().setInitialTab(subTabIndex);
    }
    controller.navigateToApprovals();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B45B0).withValues(alpha: 0.12),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: two stat tiles
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 16.h),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _HeroStatTile(
                      icon: Icons.hourglass_top_rounded,
                      accent: AppColors.warningOrange,
                      accentBg: AppColors.amberBg,
                      label: 'Pending',
                      value: controller.pendingRequestsCount.value.toString(),
                      onTap: () => _openApprovalsTab(0),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60.h,
                    color: AppColors.slate100,
                  ),
                  Expanded(
                    child: _HeroStatTile(
                      icon: Icons.help_outline_rounded,
                      accent: AppColors.primary,
                      accentBg: AppColors.purpleSurface,
                      label: 'Clarification',
                      value:
                          controller.inClarificationCount.value.toString(),
                      onTap: () => _openApprovalsTab(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom: full-width Approved strip with gradient tint
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(22.r),
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.mintBg,
                  const Color(0xFFF0FDF4),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Obx(
              () => Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1410B981),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.successGreen,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'APPROVED THIS PERIOD',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF047857),
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '₹${CurrencyFormatter.inr(controller.approvedAmount.value)}',
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF064E3B),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
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
}

class _HeroStatTile extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final Color accentBg;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _HeroStatTile({
    required this.icon,
    required this.accent,
    required this.accentBg,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inner = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accent, size: 18.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSlate,
              letterSpacing: 0.7,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return inner;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.04),
        child: inner,
      ),
    );
  }
}
