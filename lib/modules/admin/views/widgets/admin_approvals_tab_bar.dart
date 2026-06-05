import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';

/// Horizontally-scrollable chip rail. Replaces the stock Material
/// TabBar so we can show a live count next to each label and have full
/// control of the visual treatment (filled purple pill when active,
/// white border-card when idle). Designed to never overflow on any
/// phone width — chips size to their content and scroll horizontally.
class AdminApprovalsTabBar extends StatelessWidget {
  const AdminApprovalsTabBar({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppText.tabPending,
      AppText.tabApproved,
      AppText.unpaid,
      AppText.clarification,
      AppText.tabRejected,
    ];
    return SizedBox(
      height: 56.h,
      child: AnimatedBuilder(
        animation: tabController,
        builder: (_, _) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 6.h),
            itemCount: labels.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (_, i) => _StatusChip(
              label: labels[i],
              selected: tabController.index == i,
              onTap: () => tabController.animateTo(i),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 11.h),
        decoration: BoxDecoration(
          // Inactive: solid slate-200 so chips pop against the slate-50
          // page bg. Active: brand purple.
          color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.32),
                    blurRadius: 14.r,
                    offset: Offset(0, 5.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
