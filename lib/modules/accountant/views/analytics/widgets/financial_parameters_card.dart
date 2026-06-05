import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import '../../../controllers/accountant_analytics_controller.dart';
import 'spend_section_helpers.dart';

/// Report-parameters card on the Financial Reports screen.
///
/// Two-column date range row → category dropdown → Generate Preview
/// button. Tightly coupled to [AccountantAnalyticsController] (dropdown
/// items come from the loaded report summary, date picker is context-
/// dependent), so the widget accepts the controller directly rather
/// than re-routing every field through the constructor. Extracted from
/// `financial_reports_view.dart`.
class FinancialParametersCard extends StatelessWidget {
  final AccountantAnalyticsController controller;

  const FinancialParametersCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SpendSectionCard(
      icon: Icons.tune_rounded,
      title: AppText.reportParameters,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.pickDateRange(context),
            child: Row(
              children: [
                Expanded(
                  child: _dateBlock(
                    label: AppText.startDate,
                    obsDate: controller.startDate,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _dateBlock(
                    label: AppText.endDate,
                    obsDate: controller.endDate,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            AppText.category.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSlate,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            // "All Categories" is always present as the first option so
            // users can clear the filter. Backend categories follow.
            final backendCats =
                controller.reportSummary.value?.filters.categories ??
                    const <String>[];
            final items = <String>['All Categories', ...backendCats];

            // If the controller's current value isn't in the list (e.g.
            // backend hasn't loaded yet, or returned a different set on
            // refresh), fall back to "All Categories" so the dropdown
            // never shows a phantom selection.
            final currentValue =
                items.contains(controller.reportCategory.value)
                    ? controller.reportCategory.value
                    : 'All Categories';

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentValue,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20.sp, color: AppColors.textSlate),
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, color: AppColors.textDark),
                  dropdownColor: Colors.white,
                  items: items
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e == 'All Categories'
                                ? e
                                : _prettyCategory(e),
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: controller.onReportCategoryChanged,
                ),
              ),
            );
          }),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: controller.generatePreview,
              icon: Icon(Icons.refresh_rounded, size: 18.sp),
              label: Text(
                AppText.generatePreview,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

  Widget _dateBlock({required String label, required Rx<DateTime> obsDate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSlate,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MM/dd/yyyy').format(obsDate.value),
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Icon(Icons.calendar_today_rounded,
                    size: 14.sp, color: AppColors.textSlate),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _prettyCategory(String raw) {
    if (raw.isEmpty) return 'Uncategorised';
    return raw
        .split('_')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}
