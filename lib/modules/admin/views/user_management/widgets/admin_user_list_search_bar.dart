import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';

class AdminUserListSearchBar extends StatelessWidget {
  const AdminUserListSearchBar({super.key});

  static const Color _bgB = Color(0xFFF8F7FF);
  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink300 = Color(0xFFCBD5E1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgB,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
      ),
      child: TextField(
        style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: AppText.searchUsersHint,
          hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: _ink300),
          prefixIcon:
              Icon(Icons.search_rounded, color: AppColors.primary, size: 20.sp),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}
