import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_colors.dart';
import '../../controllers/my_requests_controller.dart';

/// Horizontal filter chip row for the Requestor "My Requests" screen.
///
/// Wraps the chips in an [Obx] so selection state stays reactive while
/// keeping the parent slim. Tapping a chip delegates to
/// `controller.changeTab(index)`.
class MyRequestsFilterChips extends StatelessWidget {
  final MyRequestsController controller;

  const MyRequestsFilterChips({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(
        () => Row(
          children: [
            _chip(AppText.filterAll, 0),
            SizedBox(width: 8.w),
            _chip(AppText.filterPending, 1),
            SizedBox(width: 8.w),
            _chip(AppText.filterClarification, 5),
            SizedBox(width: 8.w),
            _chip(AppText.filterApproved, 2),
            SizedBox(width: 8.w),
            _chip(AppText.filterRejected, 3),
            SizedBox(width: 8.w),
            _chip('Unpaid', 4),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int index) {
    final selected = controller.currentTab.value == index;
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSlate,
          ),
        ),
      ),
    );
  }
}
