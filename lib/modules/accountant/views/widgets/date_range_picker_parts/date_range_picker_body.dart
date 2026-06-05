import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/app_colors.dart';
import 'date_range_picker_date_field.dart';
import 'date_range_picker_preset.dart';

/// Body section of [AppDateRangePickerDialog] containing the quick-preset
/// chips row and the custom Start / End range row.
class DateRangePickerBody extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final DateRangePreset? activePreset;
  final ValueChanged<DateRangePreset> onPresetSelected;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final String Function(DateTime) formatDate;

  const DateRangePickerBody({
    super.key,
    required this.start,
    required this.end,
    required this.activePreset,
    required this.onPresetSelected,
    required this.onPickStart,
    required this.onPickEnd,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick presets
          Text(
            'QUICK PRESETS',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSlate,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              DateRangePickerPresetChip(
                label: 'Last 7 days',
                preset: DateRangePreset.last7,
                active: activePreset,
                onSelected: onPresetSelected,
              ),
              DateRangePickerPresetChip(
                label: 'Last 30 days',
                preset: DateRangePreset.last30,
                active: activePreset,
                onSelected: onPresetSelected,
              ),
              DateRangePickerPresetChip(
                label: 'This month',
                preset: DateRangePreset.thisMonth,
                active: activePreset,
                onSelected: onPresetSelected,
              ),
              DateRangePickerPresetChip(
                label: 'Last 3 months',
                preset: DateRangePreset.last90,
                active: activePreset,
                onSelected: onPresetSelected,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Custom range
          Text(
            'CUSTOM RANGE',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSlate,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: DateRangePickerDateField(
                  label: 'START',
                  value: start,
                  onTap: onPickStart,
                  formatDate: formatDate,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 16.sp, color: AppColors.slate300),
              ),
              Expanded(
                child: DateRangePickerDateField(
                  label: 'END',
                  value: end,
                  onTap: onPickEnd,
                  formatDate: formatDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
