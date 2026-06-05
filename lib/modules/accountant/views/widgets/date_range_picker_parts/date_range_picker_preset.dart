import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/app_colors.dart';

/// Quick-preset options for the date-range picker.
enum DateRangePreset { last7, last30, thisMonth, lastMonth, last90 }

/// A single pill-shaped chip that represents a preset selection.
class DateRangePickerPresetChip extends StatelessWidget {
  final String label;
  final DateRangePreset preset;
  final DateRangePreset? active;
  final ValueChanged<DateRangePreset> onSelected;

  const DateRangePickerPresetChip({
    super.key,
    required this.label,
    required this.preset,
    required this.active,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = preset == active;
    return GestureDetector(
      onTap: () => onSelected(preset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.purpleSurface,
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.primary,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
