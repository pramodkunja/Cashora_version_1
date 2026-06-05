import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/skeletons/page_skeletons.dart';
import '../../../../data/models/accountant_reports_model.dart';
import '../../controllers/accountant_analytics_controller.dart';
import 'widgets/spend_trend_chart.dart';
import 'widgets/spend_score_card.dart';
import 'widgets/spend_filter_card.dart';
import 'widgets/spend_section_helpers.dart';
import 'widgets/spend_analytics_header.dart';

class SpendAnalyticsView extends GetView<AccountantAnalyticsController> {
  const SpendAnalyticsView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          Obx(() {
            final tr = controller.selectedTimeRange.value;
            final subtitle = tr.isNotEmpty &&
                    tr.toLowerCase() != 'time range'
                ? '$tr · Spending insights'
                : 'Insights into your spending';
            return SpendAnalyticsHeader(subtitle: subtitle);
          }),
          Expanded(
            child: Obx(() {
              final data = controller.spendAnalytics.value;

              // No data yet AND no error → we're either before the
              // post-frame `loadIfNeeded` fires, or mid-fetch. Either
              // way, show the skeleton instead of an empty "no data"
              // state. This is what was missing before.
              if (data == null && controller.errorMessage.isEmpty) {
                return const SpendAnalyticsSkeleton();
              }

              if (data == null) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.errorRed),
                  ),
                );
              }
              return _buildContent(data);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SpendAnalyticsModel data) {
    // ── Comprehensive filter options ────────────────────────────────
    // Time range: backend accepts {30d / 90d / 180d / 1y} via the
    // _mapTimeRange helper in AccountantRepository. We always show all
    // four — the values are well known and don't depend on data.
    const timeRanges = <String>[
      'Last 30 days',
      'Last 3 months',
      'Last 6 months',
      'Last year',
    ];

    // Departments: start with "All Departments", then merge anything the
    // backend reports so org-specific names show up too.
    final departments = <String>[
      'All Departments',
      ...data.filters.departments
          .cast<String>()
          .where((d) => d.trim().isNotEmpty &&
              d.toLowerCase() != 'department' &&
              d.toLowerCase() != 'all departments'),
    ];

    // Categories: known enum set + anything extra the backend ships.
    const knownCategoryKeys = <String>[
      'office_supplies',
      'travel',
      'meals',
      'software',
      'hardware',
      'transport',
      'accommodation',
      'entertainment',
      'fuel',
    ];
    final categoryKeys = <String>{
      'All Categories',
      ...knownCategoryKeys,
      ...data.filters.categories
          .cast<String>()
          .where((c) => c.trim().isNotEmpty &&
              c.toLowerCase() != 'category' &&
              c.toLowerCase() != 'all categories'),
    }.toList();

    final colors = [
      AppColors.primary,
      AppColors.indigo,
      AppColors.successGreen,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filters ─────────────────────────────────────────────────
          Text(
            'FILTERS',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSlate,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 10.h),
          // Three inline dropdowns in one card, separated by thin
          // dividers. Always visible, all three on a single row, no
          // bottom sheet needed.
          SpendFilterCard(
            timeRanges: timeRanges,
            departments: departments,
            categoryKeys: categoryKeys,
            selectedTimeRange: controller.selectedTimeRange,
            selectedDepartment: controller.selectedDepartment,
            selectedCategory: controller.selectedCategory,
            onTimeRangeChanged: controller.onTimeRangeChanged,
            onDepartmentChanged: controller.onDepartmentChanged,
            onCategoryChanged: controller.onCategoryChanged,
          ),

          SizedBox(height: 20.h),

          // Score Cards
          Row(
            children: [
              Expanded(
                child: SpendScoreCard(
                  title: AppText.totalSpend,
                  value:
                      '₹${data.scoreCards.totalSpend.amount.toStringAsFixed(0)}',
                  trend: data.scoreCards.totalSpend.trendText,
                  isUp: data.scoreCards.totalSpend.isPositiveTrend,
                  icon: Icons.payments_rounded,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SpendScoreCard(
                  title: AppText.avgTransaction,
                  value:
                      '₹${data.scoreCards.avgTransaction.amount.toStringAsFixed(0)}',
                  trend: data.scoreCards.avgTransaction.trendText,
                  isUp: data.scoreCards.avgTransaction.isPositiveTrend,
                  icon: Icons.receipt_long_rounded,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Trend graph
          SpendSectionCard(
            icon: Icons.timeline_rounded,
            title: AppText.monthlyTrend,
            trailing: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: data.monthlyTrend.isPositiveTrend ? AppColors.mintBg : AppColors.redBg,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                data.monthlyTrend.trendSummaryText,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: data.monthlyTrend.isPositiveTrend ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
            ),
            child: SizedBox(
              height: 180.h,
              child: SpendTrendChart(trend: data.monthlyTrend),
            ),
          ),

          SizedBox(height: 16.h),

          // Spend by Category
          SpendSectionCard(
            icon: Icons.pie_chart_rounded,
            title: AppText.spendByCategory,
            child: data.spendByCategory.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'No category data',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp, color: AppColors.textSlate),
                    ),
                  )
                : Row(
                    children: [
                      SizedBox(
                        height: 110.w,
                        width: 110.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 34,
                                sections: data.spendByCategory
                                    .asMap()
                                    .entries
                                    .map<PieChartSectionData>((e) {
                                  return PieChartSectionData(
                                    color: colors[e.key % colors.length],
                                    value: e.value.percentage,
                                    radius: 18,
                                    showTitle: false,
                                  );
                                }).toList(),
                              ),
                            ),
                            Text(
                              'Total',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          children:
                              data.spendByCategory.asMap().entries.map<Widget>((e) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: SpendLegendRow(
                                colors[e.key % colors.length],
                                e.value.categoryName,
                                '${e.value.percentage.toStringAsFixed(1)}%',
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ),

          SizedBox(height: 16.h),

          // Department Spend
          SpendSectionCard(
            icon: Icons.business_rounded,
            title: AppText.departmentSpend,
            child: data.departmentSpend.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'No department data',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp, color: AppColors.textSlate),
                    ),
                  )
                : Column(
                    children:
                        data.departmentSpend.asMap().entries.map<Widget>((e) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: SpendProgressRow(
                          e.value.departmentName,
                          '₹${e.value.amount.toStringAsFixed(0)}',
                          e.value.progressRatio,
                          colors[e.key % colors.length],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          SizedBox(height: 20.h),

          // Custom Reports CTA
          GestureDetector(
            onTap: () =>
                Get.toNamed(AppRoutes.ACCOUNTANT_FINANCIAL_REPORTS),
            child: Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B55CE), Color(0xFF8B74E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 16.r,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.description_rounded,
                        color: Colors.white, size: 22.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.customReports,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          AppText.generateExportInsights,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
