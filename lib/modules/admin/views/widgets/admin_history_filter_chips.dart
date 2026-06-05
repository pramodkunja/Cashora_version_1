import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/admin_history_controller.dart';

/// Horizontal filter chip rail (All / Approved / Rejected / Clarified) shown
/// directly under the gradient header. Tapping a chip calls
/// [AdminHistoryController.updateFilter] and the active chip pops with the
/// brand purple fill + soft shadow.
class AdminHistoryFilterChips extends StatelessWidget {
  const AdminHistoryFilterChips({super.key, required this.controller});

  final AdminHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 6.h),
          physics: const BouncingScrollPhysics(),
          children: [
            _chip(AppText.filterAll, 'All'),
            SizedBox(width: 10.w),
            _chip(AppText.filterApproved, 'Approved'),
            SizedBox(width: 10.w),
            _chip(AppText.filterRejected, 'Rejected'),
            SizedBox(width: 10.w),
            _chip(AppText.clarified, 'Clarified'),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = controller.selectedFilter.value == value;
    return GestureDetector(
      onTap: () => controller.updateFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
        decoration: BoxDecoration(
          // Inactive: solid slate-200 so the chip clearly pops against
          // the slate-50 page bg. Active: brand purple.
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
            // Pure white on purple; near-black on the slate fill — both
            // directly readable against their respective chip colours.
            color: selected ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
