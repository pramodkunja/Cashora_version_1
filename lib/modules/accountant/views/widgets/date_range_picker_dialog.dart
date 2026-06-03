import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';

/// A purple-themed date-range picker dialog that matches the rest of the
/// app's design system. Renders as a centred rounded card with two quick
/// presets, a Start / End row, and Cancel / Apply actions.
///
/// Returns the picked range (or `null` if cancelled) via `Navigator.pop`.
class AppDateRangePickerDialog extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final DateTime firstDate;
  final DateTime lastDate;

  const AppDateRangePickerDialog({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<AppDateRangePickerDialog> createState() =>
      _AppDateRangePickerDialogState();
}

class _AppDateRangePickerDialogState extends State<AppDateRangePickerDialog> {

  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  // ── Preset helpers ─────────────────────────────────────────────────
  void _applyPreset(_Preset p) {
    final now = DateTime.now();
    DateTime newStart;
    DateTime newEnd = DateTime(now.year, now.month, now.day);
    switch (p) {
      case _Preset.last7:
        newStart = newEnd.subtract(const Duration(days: 6));
        break;
      case _Preset.last30:
        newStart = newEnd.subtract(const Duration(days: 29));
        break;
      case _Preset.thisMonth:
        newStart = DateTime(now.year, now.month, 1);
        break;
      case _Preset.lastMonth:
        final firstOfThisMonth = DateTime(now.year, now.month, 1);
        newEnd = firstOfThisMonth.subtract(const Duration(days: 1));
        newStart = DateTime(newEnd.year, newEnd.month, 1);
        break;
      case _Preset.last90:
        newStart = newEnd.subtract(const Duration(days: 89));
        break;
    }
    if (newStart.isBefore(widget.firstDate)) newStart = widget.firstDate;
    if (newEnd.isAfter(widget.lastDate)) newEnd = widget.lastDate;
    setState(() {
      _start = newStart;
      _end = newEnd;
    });
  }

  _Preset? get _activePreset {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!_sameDay(_end, today)) return null;
    if (_sameDay(_start, today.subtract(const Duration(days: 6)))) {
      return _Preset.last7;
    }
    if (_sameDay(_start, today.subtract(const Duration(days: 29)))) {
      return _Preset.last30;
    }
    if (_sameDay(_start, DateTime(now.year, now.month, 1))) {
      return _Preset.thisMonth;
    }
    if (_sameDay(_start, today.subtract(const Duration(days: 89)))) {
      return _Preset.last90;
    }
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]}, ${d.year}';

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: widget.firstDate,
      lastDate: _end,
      helpText: 'Start date',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _start = picked;
      });
    }
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: _start,
      lastDate: widget.lastDate,
      helpText: 'End date',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _end = picked;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final daysSpan = _end.difference(_start).inDays + 1;
    final active = _activePreset;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B45B0).withValues(alpha: 0.18),
              blurRadius: 32.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Gradient header ──────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.date_range_rounded,
                        color: Colors.white, size: 18.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Select Date Range',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$daysSpan day${daysSpan == 1 ? '' : 's'} selected',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: Colors.white, size: 16.sp),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Padding(
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
                      _presetChip('Last 7 days', _Preset.last7, active),
                      _presetChip('Last 30 days', _Preset.last30, active),
                      _presetChip('This month', _Preset.thisMonth, active),
                      _presetChip('Last 3 months', _Preset.last90, active),
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
                      Expanded(child: _dateField('START', _start, _pickStart)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 16.sp, color: AppColors.slate300),
                      ),
                      Expanded(child: _dateField('END', _end, _pickEnd)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Footer ───────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24.r),
                ),
                border: Border(top: BorderSide(color: AppColors.slate100, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.slate300, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSlate,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(
                          DateTimeRange(start: _start, end: _end),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Apply Range',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(String label, _Preset preset, _Preset? active) {
    final selected = preset == active;
    return GestureDetector(
      onTap: () => _applyPreset(preset),
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

  Widget _dateField(String label, DateTime value, VoidCallback onTap) {
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
                    _formatDate(value),
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

enum _Preset { last7, last30, thisMonth, lastMonth, last90 }
