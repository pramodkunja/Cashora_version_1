import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

import 'package:get/get.dart';

class AppTextStyles {
  // Headings
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: Get.theme.textTheme.bodyLarge?.color,
  );

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: Get.theme.textTheme.bodyLarge?.color,
  );

  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: Get.theme.textTheme.bodyLarge?.color,
  );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Get.theme.textTheme.bodyMedium?.color,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color:
        Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
        AppColors.textSlate,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: Get.theme.textTheme.bodySmall?.color ?? AppColors.textLight,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Specific Styles
  static TextStyle get amountDisplay => GoogleFonts.inter(
    fontSize: 36.sp,
    fontWeight: FontWeight.w800,
    color: Get.theme.primaryColor, // Use primary color for money or theme text
  );

  static TextStyle get hintText =>
      GoogleFonts.inter(fontSize: 15.sp, color: AppColors.textLight);
}
