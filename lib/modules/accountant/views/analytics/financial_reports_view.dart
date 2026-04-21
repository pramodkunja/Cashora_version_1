import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/accountant_reports_model.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/app_loader.dart';
import '../../controllers/accountant_analytics_controller.dart';

class FinancialReportsView extends GetView<AccountantAnalyticsController> {
  const FinancialReportsView({super.key});

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              child: Column(
                children: [
                  _parametersCard(context),
                  SizedBox(height: 16.h),
                  _previewCard(),
                  SizedBox(height: 16.h),
                  _exportButtons(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
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
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              AppText.financialReports,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded,
                color: Colors.white, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _parametersCard(BuildContext context) {
    return _card(
      icon: Icons.tune_rounded,
      title: AppText.reportParameters,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range
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

          // Category
          Text(
            AppText.category.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: _slate500,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final filters = controller.reportSummary.value?.filters.categories ??
                ['All Categories'];
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filters.contains(controller.reportCategory.value)
                      ? controller.reportCategory.value
                      : (filters.isNotEmpty
                          ? filters.first
                          : 'All Categories'),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20.sp, color: _slate500),
                  style: GoogleFonts.inter(fontSize: 14.sp, color: _slate900),
                  dropdownColor: Colors.white,
                  items: filters
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
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
                backgroundColor: _purple,
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

  Widget _dateBlock({required String label, required Rx<DateTime> obsDate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: _slate500,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _bg,
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
                    color: _slate900,
                  ),
                ),
                Icon(Icons.calendar_today_rounded,
                    size: 14.sp, color: _slate500),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewCard() {
    return Obx(() {
      if (controller.isReportLoading.value &&
          controller.reportSummary.value == null) {
        return Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const AppLoader(),
        );
      }
      if (controller.errorMessage.isNotEmpty &&
          controller.reportSummary.value == null) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Text(
              controller.errorMessage.value,
              style: GoogleFonts.inter(
                  fontSize: 13.sp, color: AppColors.errorRed),
            ),
          ),
        );
      }
      final summary = controller.reportSummary.value?.previewSummary;
      if (summary == null) {
        return Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.analytics_outlined,
                    size: 40.sp, color: _slate300),
                SizedBox(height: 10.h),
                Text(
                  'Generate preview to see results',
                  style: GoogleFonts.inter(
                      fontSize: 13.sp, color: _slate500),
                ),
              ],
            ),
          ),
        );
      }

      return _buildBeautifulPreview(summary);
    });
  }

  // ────────────────────────── Beautiful preview ────────────────────────────

  Widget _buildBeautifulPreview(PreviewSummary summary) {
    final txns = summary.transactions;
    final count = txns.length;
    final average = count > 0 ? summary.totalExpenses / count : 0.0;

    // Group totals by category for the breakdown chart.
    final Map<String, double> byCategory = {};
    for (final t in txns) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
    final categoryEntries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categoryEntries.take(5).toList();
    final maxCategoryTotal = topCategories.isEmpty
        ? 1.0
        : topCategories.first.value;

    return Column(
      children: [
        // ── Hero total card ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(22.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: _purple.withOpacity(0.25),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
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
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 18.sp),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    AppText.totalExpenses.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  if (summary.monthYear.isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        summary.monthYear,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '₹${_formatMoney(summary.totalExpenses)}',
                  style: GoogleFonts.inter(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: _heroStat(
                      label: 'Transactions',
                      value: '$count',
                      icon: Icons.receipt_long_rounded,
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 36.h,
                      color: Colors.white.withOpacity(0.2)),
                  Expanded(
                    child: _heroStat(
                      label: 'Average',
                      value: '₹${_formatMoney(average)}',
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 36.h,
                      color: Colors.white.withOpacity(0.2)),
                  Expanded(
                    child: _heroStat(
                      label: 'Categories',
                      value: '${byCategory.length}',
                      icon: Icons.category_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // ── Category breakdown ───────────────────────────────────────────
        if (topCategories.isNotEmpty)
          _card(
            icon: Icons.pie_chart_rounded,
            title: 'Top Categories',
            trailing: Text(
              '${topCategories.length} of ${byCategory.length}',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: _slate500,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Column(
              children: topCategories.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
                final share = summary.totalExpenses > 0
                    ? c.value / summary.totalExpenses
                    : 0.0;
                final barRatio = c.value / maxCategoryTotal;
                final color = _categoryColors[i % _categoryColors.length];
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
                              _prettyCategory(c.key),
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: _slate900,
                              ),
                            ),
                          ),
                          Text(
                            '₹${_formatMoney(c.value)}',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: _slate900,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '${(share * 100).toStringAsFixed(0)}%',
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
          ),

        if (topCategories.isNotEmpty) SizedBox(height: 16.h),

        // ── Transactions list ────────────────────────────────────────────
        _card(
          icon: Icons.receipt_long_rounded,
          title: 'Transactions',
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: _purple,
              ),
            ),
          ),
          child: txns.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 28.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 36.sp, color: _slate300),
                        SizedBox(height: 8.h),
                        Text(
                          'No transactions in this period',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: _slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: txns.asMap().entries.map((entry) {
                    final i = entry.key;
                    final t = entry.value;
                    final color = _categoryColors[
                        byCategory.keys.toList().indexOf(t.category) %
                            _categoryColors.length];
                    return _transactionRow(t, color, i == txns.length - 1);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _heroStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12.sp, color: Colors.white.withOpacity(0.8)),
            SizedBox(width: 5.w),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _transactionRow(TransactionRow t, Color color, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                _iconForCategory(t.category),
                color: color,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _prettyCategory(t.category),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _slate900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _formatReadableDate(t.date),
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: _slate500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              '₹${_formatMoney(t.amount)}',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: _slate900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Color> _categoryColors = [
    Color(0xFF6B55CE),
    Color(0xFF10B981),
    Color(0xFFF97316),
    Color(0xFF0EA5E9),
    Color(0xFFEC4899),
    Color(0xFFEAB308),
    Color(0xFF64748B),
  ];

  IconData _iconForCategory(String raw) {
    final c = raw.toLowerCase();
    if (c.contains('travel')) return Icons.flight_rounded;
    if (c.contains('meal') || c.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (c.contains('software') || c.contains('saas')) {
      return Icons.computer_rounded;
    }
    if (c.contains('hardware')) return Icons.memory_rounded;
    if (c.contains('office')) return Icons.shopping_bag_rounded;
    if (c.contains('transport')) return Icons.directions_car_rounded;
    if (c.contains('accommod') || c.contains('hotel')) {
      return Icons.hotel_rounded;
    }
    if (c.contains('entertain')) return Icons.movie_rounded;
    if (c.contains('fuel')) return Icons.local_gas_station_rounded;
    return Icons.receipt_rounded;
  }

  String _prettyCategory(String raw) {
    if (raw.isEmpty) return 'Uncategorised';
    return raw
        .split('_')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return formatter.format(value);
  }

  String _formatReadableDate(String raw) {
    if (raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  Widget _exportButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: controller.exportCsv,
              icon: Icon(Icons.table_chart_rounded,
                  color: _purple, size: 16.sp),
              label: Text(
                AppText.exportCsv,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: _purple,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _purple.withOpacity(0.3)),
                backgroundColor: _purpleLight.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: controller.exportPdf,
              icon: Icon(Icons.picture_as_pdf_rounded, size: 16.sp),
              label: Text(
                AppText.exportPdf,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card({
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

}
