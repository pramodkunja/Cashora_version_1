import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';
import 'cashora_colors.dart';

/// Standard M3 floating-label `InputDecoration`. Labels start inside the
/// field, glide into the border on focus or fill, and turn primary purple.
///
/// Use with `TextField`, `TextFormField`, `DropdownButtonFormField`, etc.
InputDecoration cashoraInputDecoration({
  required String label,
  required IconData icon,
  Widget? suffix,
  bool dense = false,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: CashoraColors.ink500,
    ),
    floatingLabelStyle: GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
    prefixIcon: Padding(
      padding: EdgeInsets.only(left: 12.w, right: 6.w),
      child: Icon(icon, color: CashoraColors.ink500, size: 18.sp),
    ),
    prefixIconConstraints:
        BoxConstraints(minWidth: 36.w, minHeight: 36.h),
    suffixIcon: suffix,
    filled: true,
    fillColor: CashoraColors.surface,
    isDense: dense,
    contentPadding:
        EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
    hintStyle:
        GoogleFonts.inter(fontSize: 13.sp, color: CashoraColors.ink300),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: CashoraColors.ink200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: CashoraColors.ink200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: AppColors.primary, width: 1.8),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: CashoraColors.ink200),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
    ),
  );
}
