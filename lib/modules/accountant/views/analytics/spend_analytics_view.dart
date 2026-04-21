import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/app_loader.dart';
import '../../../../data/models/accountant_reports_model.dart';
import '../../controllers/accountant_analytics_controller.dart';

class SpendAnalyticsView extends GetView<AccountantAnalyticsController> {
  const SpendAnalyticsView({super.key});

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _red = AppColors.errorRed;
  static const _redBg = Color(0xFFFEF2F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.isSpendLoading.value &&
                  controller.spendAnalytics.value == null) {
                return const AppLoader();
              }
              if (controller.errorMessage.isNotEmpty &&
                  controller.spendAnalytics.value == null) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: GoogleFonts.inter(fontSize: 13.sp, color: _red),
                  ),
                );
              }
              final data = controller.spendAnalytics.value;
              if (data == null) {
                return Center(
                  child: Text(
                    'No data available',
                    style: GoogleFonts.inter(
                        fontSize: 14.sp, color: _slate500),
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
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        22.h,
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
          Expanded(
            child: Text(
              AppText.spendAnalytics,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SpendAnalyticsModel data) {
    final timeRanges = data.filters.timeRanges.isNotEmpty
        ? data.filters.timeRanges
        : ['This Month', 'Last Month'];
    final departments = data.filters.departments.isNotEmpty
        ? data.filters.departments
        : ['Department'];
    final categories = data.filters.categories.isNotEmpty
        ? data.filters.categories
        : ['Category'];

    final colors = [
      _purple,
      AppColors.indigo,
      _green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filter(controller.selectedTimeRange, timeRanges.cast<String>(),
                    controller.onTimeRangeChanged),
                SizedBox(width: 8.w),
                _filter(controller.selectedDepartment,
                    departments.cast<String>(), controller.onDepartmentChanged),
                SizedBox(width: 8.w),
                _filter(controller.selectedCategory, categories.cast<String>(),
                    controller.onCategoryChanged),
              ],
            ),
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
                color: data.monthlyTrend.isPositiveTrend ? _greenBg : _redBg,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                data.monthlyTrend.trendSummaryText,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: data.monthlyTrend.isPositiveTrend ? _green : _red,
                ),
              ),
            ),
            child: SizedBox(
              height: 180.h,
              child: data.monthlyTrend.graphData.isEmpty
                  ? Center(
                      child: Text(
                        'No graph data',
                        style: GoogleFonts.inter(
                            fontSize: 12.sp, color: _slate500),
                      ),
                    )
                  : LineChart(
                      LineChartData(
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
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= 0 &&
                                    idx < data.monthlyTrend.graphData.length) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 6.h),
                                    child: Text(
                                      data.monthlyTrend.graphData[idx]
                                          .weekOrDay,
                                      style: GoogleFonts.inter(
                                        fontSize: 10.sp,
                                        color: _slate500,
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
                            spots: data.monthlyTrend.graphData
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                    e.key.toDouble(), e.value.amount))
                                .toList(),
                            isCurved: true,
                            color: _purple,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  _purple.withOpacity(0.25),
                                  _purple.withOpacity(0.02),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          fontSize: 12.sp, color: _slate500),
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
                                color: _slate500,
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
                          fontSize: 12.sp, color: _slate500),
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
                    color: _purple.withOpacity(0.22),
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
                      color: Colors.white.withOpacity(0.18),
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
                            color: Colors.white.withOpacity(0.8),
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

  Widget _filter(RxString value, List<String> items,
      Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            value: items.contains(value.value) ? value.value : items.first,
            items: items
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: GoogleFonts.inter(
                            fontSize: 12.sp, color: _slate900),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                size: 16.sp, color: _slate500),
            isDense: true,
            dropdownColor: Colors.white,
          ),
        ),
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
            color: Colors.black.withOpacity(0.03),
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
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: _purple, size: 14.sp),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isUp ? _greenBg : _redBg,
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
                      color: isUp ? _green : _red,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      trend,
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: isUp ? _green : _red,
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
            style: GoogleFonts.inter(fontSize: 11.sp, color: _slate500),
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
                color: _slate900,
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
            color: Colors.black.withOpacity(0.03),
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
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: _purple, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _slate900,
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
              color: _slate900,
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
            color: _slate900,
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
                  color: _slate900,
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
                color: _slate900,
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
}
