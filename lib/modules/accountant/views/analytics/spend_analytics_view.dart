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

class SpendAnalyticsView extends GetView<AccountantAnalyticsController> {
  const SpendAnalyticsView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24.w,
        MediaQuery.of(context).padding.top + 18.h,
        24.w,
        26.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(Icons.insights_rounded,
                color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppText.spendAnalytics,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(() {
                  final tr = controller.selectedTimeRange.value;
                  final subtitle = tr.isNotEmpty &&
                          tr.toLowerCase() != 'time range'
                      ? '$tr · Spending insights'
                      : 'Insights into your spending';
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 11.sp,
                          color: Colors.white.withValues(alpha: 0.75)),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
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
          _buildFilterCard(
            timeRanges: timeRanges,
            departments: departments,
            categoryKeys: categoryKeys,
          ),

          SizedBox(height: 20.h),

          // Score Cards
          Row(
            children: [
              Expanded(
                child: _scoreCard(
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
                child: _scoreCard(
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
          _buildCard(
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
              child: _buildTrendChart(data.monthlyTrend),
            ),
          ),

          SizedBox(height: 16.h),

          // Spend by Category
          _buildCard(
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
                              child: _legend(
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
          _buildCard(
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
                        child: _progressRow(
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

  // ════════════════════════════════════════════════════════════════════
  // FILTER CARD — three inline dropdowns in one white card, separated
  // by thin vertical dividers. Each column has a small caps label on
  // top and the dropdown value below. Three Expanded columns share
  // width equally so it fits any phone width without scrolling.
  // ════════════════════════════════════════════════════════════════════
  Widget _buildFilterCard({
    required List<String> timeRanges,
    required List<String> departments,
    required List<String> categoryKeys,
  }) {
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
                value: controller.selectedTimeRange,
                items: timeRanges,
                onChanged: controller.onTimeRangeChanged,
              ),
            ),
            _columnDivider(),
            Expanded(
              child: _filterColumn(
                label: 'DEPT',
                value: controller.selectedDepartment,
                items: departments,
                onChanged: controller.onDepartmentChanged,
              ),
            ),
            _columnDivider(),
            Expanded(
              child: _filterColumn(
                label: 'CATEGORY',
                value: controller.selectedCategory,
                items: categoryKeys,
                onChanged: controller.onCategoryChanged,
                prettifyLabels: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    required Function(String?) onChanged,
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


  Widget _scoreCard({
    required String title,
    required String value,
    required String trend,
    required bool isUp,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 14.sp),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isUp ? AppColors.mintBg : AppColors.redBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 10.sp,
                      color: isUp ? AppColors.successGreen : AppColors.errorRed,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      trend,
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: isUp ? AppColors.successGreen : AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textSlate),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _legend(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _progressRow(
      String title, String amount, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF1F5F9),
            color: color,
            minHeight: 7.h,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(MonthlyTrend trend) {
    final points = trend.graphData;

    if (points.isEmpty) {
      return Center(
        child: Text(
          'No graph data',
          style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSlate),
        ),
      );
    }

    final maxAmount = points
        .map((p) => p.amount)
        .fold<double>(0, (m, v) => v > m ? v : m);

    debugPrint(
      '[Analytics] trend points=${points.length} max=$maxAmount '
      'values=${points.map((p) => "${p.weekOrDay}:${p.amount}").join(", ")}',
    );

    if (maxAmount <= 0) {
      return Center(
        child: Text(
          'No spend in this range yet',
          style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSlate),
        ),
      );
    }

    final isSingle = points.length == 1;
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].amount),
      if (isSingle) FlSpot(1, points[0].amount),
    ];
    final lastX = (spots.length - 1).toDouble();
    final maxY = maxAmount * 1.15;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: lastX,
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < points.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      points[idx].weekOrDay,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: AppColors.textSlate,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: !isSingle,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(show: isSingle),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
