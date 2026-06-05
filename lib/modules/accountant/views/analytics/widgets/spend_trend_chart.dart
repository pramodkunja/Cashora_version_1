import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../data/models/accountant_reports_model.dart';

/// Line chart for the monthly-trend section of the Spend Analytics
/// screen. Extracted from `spend_analytics_view.dart` to keep the parent
/// under the 400-line target. Renders byte-identical output.
class SpendTrendChart extends StatelessWidget {
  final MonthlyTrend trend;

  const SpendTrendChart({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    final points = trend.graphData;

    if (points.isEmpty) {
      return Center(
        child: Text(
          'No graph data',
          style: GoogleFonts.inter(
              fontSize: 12.sp, color: AppColors.textSlate),
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
          style: GoogleFonts.inter(
              fontSize: 12.sp, color: AppColors.textSlate),
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
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
