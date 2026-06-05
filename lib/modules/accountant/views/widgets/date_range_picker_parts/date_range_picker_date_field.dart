import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/app_colors.dart';

/// A single START / END date field used inside the custom-range row.
class DateRangePickerDateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  const DateRangePickerDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.slate100, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSlate,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 12.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    formatDate(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
