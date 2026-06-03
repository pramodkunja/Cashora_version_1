/// Read the first non-null value among the given keys. Lets fromJson tolerate
/// both camelCase (what the frontend-driven contract used) and snake_case
/// (FastAPI's default serialization), so a backend response in either
/// convention parses correctly.
dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    if (json.containsKey(k) && json[k] != null) return json[k];
  }
  return null;
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return const {};
}

List<dynamic> _asList(dynamic v) => v is List ? v : const [];

class ReportSummaryModel {
  final Filters filters;
  final PreviewSummary previewSummary;

  ReportSummaryModel({required this.filters, required this.previewSummary});

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    // Backend (FastAPI) flat shape:
    //   { total_amount, count, by_category: {cat: amount}, by_status: {...} }
    // Map this into the nested `previewSummary` view-model the UI expects.
    final isFlat = json.containsKey('total_amount') ||
        json.containsKey('by_category') ||
        json.containsKey('by_status');

    if (isFlat) {
      final totalAmount = (_pick(json, ['total_amount']) as num? ?? 0).toDouble();
      final byCategory = _asMap(_pick(json, ['by_category']));

      // Each (category, amount) pair becomes a transaction row in the
      // preview table. Date is left blank — backend doesn't break it down
      // per-transaction at this aggregation level.
      final transactions = byCategory.entries
          .map((e) => TransactionRow(
                date: '',
                category: e.key.toString(),
                amount: (e.value as num? ?? 0).toDouble(),
              ))
          .toList();

      final now = DateTime.now();
      const monthNames = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];

      return ReportSummaryModel(
        filters: Filters(
          categories: byCategory.keys.map((k) => k.toString()).toList(),
          timeRanges: const [],
          departments: const [],
        ),
        previewSummary: PreviewSummary(
          monthYear: '${monthNames[now.month]} ${now.year}',
          totalExpenses: totalAmount,
          transactions: transactions,
        ),
      );
    }

    // Legacy nested shape (kept so a contract switch doesn't break us).
    return ReportSummaryModel(
      filters: Filters.fromJson(_asMap(_pick(json, ['filters']))),
      previewSummary: PreviewSummary.fromJson(
        _asMap(_pick(json, ['previewSummary', 'preview_summary'])),
      ),
    );
  }
}

class SpendAnalyticsModel {
  final Filters filters;
  final ScoreCards scoreCards;
  final MonthlyTrend monthlyTrend;
  final List<SpendCategory> spendByCategory;
  final List<DepartmentSpend> departmentSpend;

  SpendAnalyticsModel({
    required this.filters,
    required this.scoreCards,
    required this.monthlyTrend,
    required this.spendByCategory,
    required this.departmentSpend,
  });

  factory SpendAnalyticsModel.fromJson(Map<String, dynamic> json) {
    // Backend (FastAPI) flat shape:
    //   {
    //     total,
    //     by_period: [{year, month, total}],
    //     by_department: [{department, total}],
    //     by_category: {cat: amount}
    //   }
    final isFlat = json.containsKey('by_period') ||
        json.containsKey('by_department') ||
        (json.containsKey('by_category') &&
            json['by_category'] is Map) ||
        (json.containsKey('total') && !json.containsKey('scoreCards'));

    if (isFlat) {
      final total = (_pick(json, ['total']) as num? ?? 0).toDouble();

      // by_category: Map<categoryName, amount> → SpendCategory[] with %
      final byCategoryMap = _asMap(_pick(json, ['by_category']));
      double catSum = 0;
      for (final v in byCategoryMap.values) {
        if (v is num) catSum += v.toDouble();
      }
      final spendByCategory = byCategoryMap.entries.map((e) {
        final amount = (e.value as num? ?? 0).toDouble();
        return SpendCategory(
          categoryName: e.key.toString(),
          percentage: catSum > 0 ? (amount / catSum) * 100 : 0,
        );
      }).toList();

      // by_department: [{department, total}] → DepartmentSpend[] with ratio
      final byDept = _asList(_pick(json, ['by_department']));
      double maxDept = 0;
      for (final d in byDept) {
        final v = (d is Map ? d['total'] : 0) as num? ?? 0;
        if (v.toDouble() > maxDept) maxDept = v.toDouble();
      }
      final departmentSpend = byDept.map((d) {
        final m = _asMap(d);
        final amt = (m['total'] as num? ?? 0).toDouble();
        return DepartmentSpend(
          departmentName: m['department']?.toString() ?? '',
          amount: amt,
          progressRatio: maxDept > 0 ? amt / maxDept : 0,
        );
      }).toList();

      // by_period: [{year, month, total}] → graphData[]
      const monthNames = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final periods = _asList(_pick(json, ['by_period']));
      final graphData = periods.map((p) {
        final m = _asMap(p);
        final year = (m['year'] as num? ?? 0).toInt();
        final month = (m['month'] as num? ?? 0).toInt();
        final amt = (m['total'] as num? ?? 0).toDouble();
        final label = month >= 1 && month <= 12
            ? '${monthNames[month]} ${year.toString().substring(year.toString().length - 2)}'
            : '$year-$month';
        return GraphData(weekOrDay: label, amount: amt);
      }).toList();

      // Trend = sign of last period vs previous period (when at least 2 points).
      String trendText = '';
      bool trendPositive = true;
      if (periods.length >= 2) {
        final last = (_asMap(periods.last)['total'] as num? ?? 0).toDouble();
        final prev =
            (_asMap(periods[periods.length - 2])['total'] as num? ?? 0).toDouble();
        if (prev > 0) {
          final pct = ((last - prev) / prev) * 100;
          trendPositive = pct >= 0;
          trendText = '${pct >= 0 ? "+" : ""}${pct.toStringAsFixed(1)}%';
        }
      }

      // Avg per period (when we have any periods).
      final avg = periods.isEmpty ? 0.0 : total / periods.length;

      return SpendAnalyticsModel(
        filters: Filters(
          categories: byCategoryMap.keys.map((k) => k.toString()).toList(),
          timeRanges: const ['This Month', 'Last 3 Months', 'Last 6 Months', 'Last Year'],
          departments: byDept
              .map((d) => _asMap(d)['department']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList(),
        ),
        scoreCards: ScoreCards(
          totalSpend: SpendCard(
            amount: total,
            trendText: trendText,
            isPositiveTrend: trendPositive,
          ),
          avgTransaction: SpendCard(
            amount: avg,
            trendText: '',
            isPositiveTrend: true,
          ),
        ),
        monthlyTrend: MonthlyTrend(
          trendSummaryText: trendText,
          isPositiveTrend: trendPositive,
          graphData: graphData,
        ),
        spendByCategory: spendByCategory,
        departmentSpend: departmentSpend,
      );
    }

    // Legacy nested shape (kept so a contract switch doesn't break us).
    return SpendAnalyticsModel(
      filters: Filters.fromJson(_asMap(_pick(json, ['filters']))),
      scoreCards: ScoreCards.fromJson(
        _asMap(_pick(json, ['scoreCards', 'score_cards'])),
      ),
      monthlyTrend: MonthlyTrend.fromJson(
        _asMap(_pick(json, ['monthlyTrend', 'monthly_trend'])),
      ),
      spendByCategory: _asList(_pick(json, ['spendByCategory', 'spend_by_category']))
          .map((item) => SpendCategory.fromJson(_asMap(item)))
          .toList(),
      departmentSpend: _asList(_pick(json, ['departmentSpend', 'department_spend']))
          .map((item) => DepartmentSpend.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class Filters {
  final List<String> categories;
  final List<String> timeRanges;
  final List<String> departments;

  Filters({
    required this.categories,
    required this.timeRanges,
    required this.departments,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      categories: _asList(_pick(json, ['categories'])).map((e) => e.toString()).toList(),
      timeRanges: _asList(_pick(json, ['timeRanges', 'time_ranges']))
          .map((e) => e.toString())
          .toList(),
      departments: _asList(_pick(json, ['departments'])).map((e) => e.toString()).toList(),
    );
  }
}

class PreviewSummary {
  final String monthYear;
  final double totalExpenses;
  final List<TransactionRow> transactions;

  PreviewSummary({
    required this.monthYear,
    required this.totalExpenses,
    required this.transactions,
  });

  factory PreviewSummary.fromJson(Map<String, dynamic> json) {
    return PreviewSummary(
      monthYear: _pick(json, ['monthYear', 'month_year'])?.toString() ?? '',
      totalExpenses:
          (_pick(json, ['totalExpenses', 'total_expenses']) as num? ?? 0).toDouble(),
      transactions: _asList(_pick(json, ['transactions']))
          .map((item) => TransactionRow.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class TransactionRow {
  final String date;
  final String category;
  final double amount;

  TransactionRow({
    required this.date,
    required this.category,
    required this.amount,
  });

  factory TransactionRow.fromJson(Map<String, dynamic> json) {
    return TransactionRow(
      date: _pick(json, ['date'])?.toString() ?? '',
      category: _pick(json, ['category'])?.toString() ?? '',
      amount: (_pick(json, ['amount']) as num? ?? 0).toDouble(),
    );
  }
}

class ScoreCards {
  final SpendCard totalSpend;
  final SpendCard avgTransaction;

  ScoreCards({required this.totalSpend, required this.avgTransaction});

  factory ScoreCards.fromJson(Map<String, dynamic> json) {
    return ScoreCards(
      totalSpend: SpendCard.fromJson(_asMap(_pick(json, ['totalSpend', 'total_spend']))),
      avgTransaction: SpendCard.fromJson(
        _asMap(_pick(json, ['avgTransaction', 'avg_transaction'])),
      ),
    );
  }
}

class SpendCard {
  final double amount;
  final String trendText;
  final bool isPositiveTrend;

  SpendCard({
    required this.amount,
    required this.trendText,
    required this.isPositiveTrend,
  });

  factory SpendCard.fromJson(Map<String, dynamic> json) {
    return SpendCard(
      amount: (_pick(json, ['amount']) as num? ?? 0).toDouble(),
      trendText: _pick(json, ['trendText', 'trend_text'])?.toString() ?? '',
      isPositiveTrend:
          _pick(json, ['isPositiveTrend', 'is_positive_trend']) == true,
    );
  }
}

class MonthlyTrend {
  final String trendSummaryText;
  final bool isPositiveTrend;
  final List<GraphData> graphData;

  MonthlyTrend({
    required this.trendSummaryText,
    required this.isPositiveTrend,
    required this.graphData,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) {
    return MonthlyTrend(
      trendSummaryText:
          _pick(json, ['trendSummaryText', 'trend_summary_text'])?.toString() ?? '',
      isPositiveTrend:
          _pick(json, ['isPositiveTrend', 'is_positive_trend']) == true,
      graphData: _asList(_pick(json, ['graphData', 'graph_data']))
          .map((item) => GraphData.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class GraphData {
  final String weekOrDay;
  final double amount;

  GraphData({required this.weekOrDay, required this.amount});

  factory GraphData.fromJson(Map<String, dynamic> json) {
    return GraphData(
      weekOrDay: _pick(json, ['weekOrDay', 'week_or_day', 'label'])?.toString() ?? '',
      amount: (_pick(json, ['amount']) as num? ?? 0).toDouble(),
    );
  }
}

class SpendCategory {
  final String categoryName;
  final double percentage;

  SpendCategory({required this.categoryName, required this.percentage});

  factory SpendCategory.fromJson(Map<String, dynamic> json) {
    return SpendCategory(
      categoryName:
          _pick(json, ['categoryName', 'category_name', 'category'])?.toString() ?? '',
      percentage: (_pick(json, ['percentage']) as num? ?? 0).toDouble(),
    );
  }
}

class DepartmentSpend {
  final double amount;
  final String departmentName;
  final double progressRatio;

  DepartmentSpend({
    required this.amount,
    required this.departmentName,
    required this.progressRatio,
  });

  factory DepartmentSpend.fromJson(Map<String, dynamic> json) {
    return DepartmentSpend(
      departmentName:
          _pick(json, ['departmentName', 'department_name', 'department'])?.toString() ??
              '',
      amount: (_pick(json, ['amount']) as num? ?? 0).toDouble(),
      progressRatio:
          (_pick(json, ['progressRatio', 'progress_ratio']) as num? ?? 0).toDouble(),
    );
  }
}
