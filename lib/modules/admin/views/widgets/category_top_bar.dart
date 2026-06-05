import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../controllers/category_controller.dart';

/// Top bar for the category list — back chevron, "Categories" title,
/// kebab menu with Seed Defaults / Show or Hide Inactive options.
class CategoryTopBar extends StatelessWidget {
  final CategoryController controller;

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);

  const CategoryTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          _circleIconButton(Icons.arrow_back_rounded, () => Get.back()),
          Expanded(
            child: Center(
              child: Text(
                'Categories',
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
          child: Icon(Icons.more_horiz_rounded, color: _ink700, size: 20.sp),
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
}
