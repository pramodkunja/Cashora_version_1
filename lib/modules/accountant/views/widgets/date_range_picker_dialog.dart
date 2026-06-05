import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import 'date_range_picker_parts/date_range_picker_body.dart';
import 'date_range_picker_parts/date_range_picker_footer.dart';
import 'date_range_picker_parts/date_range_picker_header.dart';
import 'date_range_picker_parts/date_range_picker_preset.dart';

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
  void _applyPreset(DateRangePreset p) {
    final now = DateTime.now();
    DateTime newStart;
    DateTime newEnd = DateTime(now.year, now.month, now.day);
    switch (p) {
      case DateRangePreset.last7:
        newStart = newEnd.subtract(const Duration(days: 6));
        break;
      case DateRangePreset.last30:
        newStart = newEnd.subtract(const Duration(days: 29));
        break;
      case DateRangePreset.thisMonth:
        newStart = DateTime(now.year, now.month, 1);
        break;
      case DateRangePreset.lastMonth:
        final firstOfThisMonth = DateTime(now.year, now.month, 1);
        newEnd = firstOfThisMonth.subtract(const Duration(days: 1));
        newStart = DateTime(newEnd.year, newEnd.month, 1);
        break;
      case DateRangePreset.last90:
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

  DateRangePreset? get _activePreset {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!_sameDay(_end, today)) return null;
    if (_sameDay(_start, today.subtract(const Duration(days: 6)))) {
      return DateRangePreset.last7;
    }
    if (_sameDay(_start, today.subtract(const Duration(days: 29)))) {
      return DateRangePreset.last30;
    }
    if (_sameDay(_start, DateTime(now.year, now.month, 1))) {
      return DateRangePreset.thisMonth;
    }
    if (_sameDay(_start, today.subtract(const Duration(days: 89)))) {
      return DateRangePreset.last90;
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
            DateRangePickerHeader(
              daysSpan: daysSpan,
              onClose: () => Navigator.of(context).pop(),
            ),
            DateRangePickerBody(
              start: _start,
              end: _end,
              activePreset: _activePreset,
              onPresetSelected: _applyPreset,
              onPickStart: _pickStart,
              onPickEnd: _pickEnd,
              formatDate: _formatDate,
            ),
            DateRangePickerFooter(
              onCancel: () => Navigator.of(context).pop(),
              onApply: () => Navigator.of(context).pop(
                DateTimeRange(start: _start, end: _end),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
