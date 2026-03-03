import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../controllers/accountant_analytics_controller.dart';

class SpendAnalyticsView extends GetView<AccountantAnalyticsController> {
  const SpendAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, // No back button
        title: Text(AppText.spendAnalytics, style: AppTextStyles.h2),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.tune, color: Theme.of(context).iconTheme.color),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDropdown(context, controller.selectedTimeRange, [
                    AppText.thisMonth,
                    'Last Month',
                  ]),
                  const SizedBox(width: 12),
                  _buildDropdown(context, controller.selectedDepartment, [
                    'Department',
                    'Sales',
                    'IT',
                  ]),
                  const SizedBox(width: 12),
                  _buildDropdown(context, controller.selectedCategory, [
                    'Category',
                    'Travel',
                    'Food',
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Score Cards
            Row(
              children: [
                Expanded(
                  child: _buildScoreCard(
                    context,
                    AppText.totalSpend,
                    '\$4,250',
                    '+12%',
                    true,
                    Icons.payments_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildScoreCard(
                    context,
                    AppText.avgTransaction,
                    '\$85.00',
                    '+2.5%',
                    true,
                    Icons.receipt_long,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly Trend Graph
            _buildSectionHeader(
              AppText.monthlyTrend,
              '+15% vs last mo',
              isPositive: true,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          Color textColor =
                              Theme.of(context).textTheme.bodySmall?.color ??
                              Colors.grey;
                          switch (value.toInt()) {
                            case 0:
                              return Text(
                                'WEEK 1',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 10,
                                ),
                              );
                            case 2:
                              return Text(
                                'WEEK 2',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 10,
                                ),
                              );
                            case 4:
                              return Text(
                                'WEEK 3',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 10,
                                ),
                              );
                            case 6:
                              return Text(
                                'WEEK 4',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 10,
                                ),
                              );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1),
                        FlSpot(1, 1.5),
                        FlSpot(2, 1.4),
                        FlSpot(3, 2.2),
                        FlSpot(3.5, 2.5),
                        FlSpot(4, 2),
                        FlSpot(5, 1.5),
                        FlSpot(6, 3),
                      ],
                      isCurved: true,
                      color: AppColors.primaryBlue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryBlue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Spend by Category
            Text(AppText.spendByCategory, style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Distribution across top categories',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSlate,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: AppColors.primaryBlue,
                                value: 45,
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: AppColors.indigo,
                                value: 25,
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: AppColors.successGreen,
                                value: 20,
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: AppColors.borderLight,
                                value: 10,
                                radius: 20,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Text(
                            'Total',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildLegendItem(
                          AppColors.primaryBlue,
                          'Office Supplies',
                          '45%',
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(AppColors.indigo, 'Travel', '25%'),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          AppColors.successGreen,
                          'Food & Bev',
                          '20%',
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          AppColors.borderLight,
                          'Others',
                          '10%',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Department Spend
            Text(AppText.departmentSpend, style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Breakdown by internal teams',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSlate,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildProgressRow(
                    'Sales',
                    '\$1,850',
                    0.8,
                    AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  _buildProgressRow(
                    'Engineering',
                    '\$1,200',
                    0.5,
                    const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressRow(
                    'Human Resources',
                    '\$800',
                    0.3,
                    const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressRow(
                    'Marketing',
                    '\$400',
                    0.15,
                    const Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Custom Reports Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Get.toNamed(AppRoutes.ACCOUNTANT_FINANCIAL_REPORTS),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.description, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.customReports,
                          style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          AppText.generateExportInsights,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    RxString value,
    List<String> items,
  ) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(value.value) ? value.value : items.first,
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: AppTextStyles.bodySmall),
                  ),
                )
                .toList(),
            onChanged: (val) => value.value = val!,
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Theme.of(context).iconTheme.color,
            ),
            isDense: true,
            dropdownColor: Theme.of(context).cardColor,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    String title,
    String value,
    String trend,
    bool isUp,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 12,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSlate),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.h2),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle, {
    bool isPositive = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h3),
            Text(
              'Spending velocity over time',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSlate,
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: isPositive ? const Color(0xFF16A34A) : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProgressRow(
    String title,
    String amount,
    double progress,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyMedium),
            Text(
              amount,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[100],
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
