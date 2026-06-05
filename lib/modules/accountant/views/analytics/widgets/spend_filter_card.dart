import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/app_colors.dart';

/// Three inline dropdowns in one white card (period / department /
/// category) — used at the top of the Spend Analytics screen. Each
/// dropdown has its own narrow Obx so dropdown state changes don't
/// rebuild the whole card. Extracted from `spend_analytics_view.dart`.
class SpendFilterCard extends StatelessWidget {
  final List<String> timeRanges;
  final List<String> departments;
  final List<String> categoryKeys;
  final RxString selectedTimeRange;
  final RxString selectedDepartment;
  final RxString selectedCategory;
  final ValueChanged<String?> onTimeRangeChanged;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onCategoryChanged;

  const SpendFilterCard({
    super.key,
    required this.timeRanges,
    required this.departments,
    required this.categoryKeys,
    required this.selectedTimeRange,
    required this.selectedDepartment,
    required this.selectedCategory,
    required this.onTimeRangeChanged,
    required this.onDepartmentChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _filterColumn(
                label: 'PERIOD',
                value: selectedTimeRange,
                items: timeRanges,
                onChanged: onTimeRangeChanged,
              ),
            ),
            _columnDivider(),
            Expanded(
              child: _filterColumn(
                label: 'DEPT',
                value: selectedDepartment,
                items: departments,
                onChanged: onDepartmentChanged,
              ),
            ),
            _columnDivider(),
            Expanded(
              child: _filterColumn(
                label: 'CATEGORY',
                value: selectedCategory,
                items: categoryKeys,
                onChanged: onCategoryChanged,
                prettifyLabels: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

  Widget _columnDivider() {
    return Container(
      width: 1,
      margin: EdgeInsets.symmetric(vertical: 12.h),
      color: const Color(0xFFF1F5F9),
    );
  }

  Widget _filterColumn({
    required String label,
    required RxString value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool prettifyLabels = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
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
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 4.h),
          DropdownButtonHideUnderline(
            child: Obx(() {
              final current =
                  items.contains(value.value) ? value.value : items.first;
              String display(String raw) =>
                  prettifyLabels ? _prettifyEnumKey(raw) : raw;
              return DropdownButton<String>(
                value: current,
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          display(e),
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (_) => items
                    .map(
                      (e) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          display(e),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16.sp, color: AppColors.textSlate),
                isExpanded: true,
                isDense: true,
                menuMaxHeight: 320.h,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Convert raw enum keys (`office_supplies`) to display labels
  /// (`Office Supplies`). Pass-through for non-snake_case strings.
  String _prettifyEnumKey(String raw) {
    if (raw.isEmpty || raw.toLowerCase() == 'all categories') return raw;
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
