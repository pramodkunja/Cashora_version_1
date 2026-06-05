import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/app_colors.dart';
import '../spend_section_helpers.dart';
import 'financial_preview_formatters.dart';

/// "Top Categories" breakdown card — dot + name + amount + share chip
/// stacked over a progress bar for each of the leading categories.
class FinancialPreviewCategories extends StatelessWidget {
  final List<MapEntry<String, double>> topCategories;
  final int totalCategoryCount;
  final double totalExpenses;
  final double maxCategoryTotal;

  const FinancialPreviewCategories({
    super.key,
    required this.topCategories,
    required this.totalCategoryCount,
    required this.totalExpenses,
    required this.maxCategoryTotal,
  });

  @override
  Widget build(BuildContext context) {
    return SpendSectionCard(
      icon: Icons.pie_chart_rounded,
      title: 'Top Categories',
      trailing: Text(
        '${topCategories.length} of $totalCategoryCount',
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          color: AppColors.textSlate,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Column(
        children: topCategories.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          final share =
              totalExpenses > 0 ? c.value / totalExpenses : 0.0;
          final barRatio = c.value / maxCategoryTotal;
          final color = FinancialPreviewFormatters
              .categoryColors[i % FinancialPreviewFormatters.categoryColors.length];
          return Padding(
            padding: EdgeInsets.only(
                bottom: i == topCategories.length - 1 ? 0 : 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        FinancialPreviewFormatters.prettyCategory(c.key),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '₹${FinancialPreviewFormatters.formatMoney(c.value)}',
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${(share * 100).toStringAsFixed(0)}%',
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: barRatio.clamp(0.0, 1.0),
                    minHeight: 6.h,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
