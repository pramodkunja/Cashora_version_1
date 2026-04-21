class ReportSummaryModel {
  final Filters filters;
  final PreviewSummary previewSummary;

  ReportSummaryModel({required this.filters, required this.previewSummary});

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      filters: Filters.fromJson(json['filters'] ?? {}),
      previewSummary: PreviewSummary.fromJson(json['previewSummary'] ?? {}),
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
    return SpendAnalyticsModel(
      filters: Filters.fromJson(json['filters'] ?? {}),
      scoreCards: ScoreCards.fromJson(json['scoreCards'] ?? {}),
      monthlyTrend: MonthlyTrend.fromJson(json['monthlyTrend'] ?? {}),
      spendByCategory: (json['spendByCategory'] as List? ?? [])
          .map((item) => SpendCategory.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      departmentSpend: (json['departmentSpend'] as List? ?? [])
          .map((item) => DepartmentSpend.fromJson(Map<String, dynamic>.from(item)))
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
      categories: (json['categories'] as List? ?? []).map((e) => e.toString()).toList(),
      timeRanges: (json['timeRanges'] as List? ?? []).map((e) => e.toString()).toList(),
      departments: (json['departments'] as List? ?? []).map((e) => e.toString()).toList(),
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
      monthYear: json['monthYear']?.toString() ?? '',
      totalExpenses: (json['totalExpenses'] ?? 0.0).toDouble(),
      transactions: (json['transactions'] as List? ?? [])
          .map((item) => TransactionRow.fromJson(Map<String, dynamic>.from(item)))
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
      date: json['date']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
    );
  }
}

class ScoreCards {
  final SpendCard totalSpend;
  final SpendCard avgTransaction;

  ScoreCards({required this.totalSpend, required this.avgTransaction});

  factory ScoreCards.fromJson(Map<String, dynamic> json) {
    return ScoreCards(
      totalSpend: SpendCard.fromJson(json['totalSpend'] ?? {}),
      avgTransaction: SpendCard.fromJson(json['avgTransaction'] ?? {}),
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
      amount: (json['amount'] ?? 0.0).toDouble(),
      trendText: json['trendText']?.toString() ?? '',
      isPositiveTrend: json['isPositiveTrend'] == true,
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
      trendSummaryText: json['trendSummaryText']?.toString() ?? '',
      isPositiveTrend: json['isPositiveTrend'] == true,
      graphData: (json['graphData'] as List? ?? [])
          .map((item) => GraphData.fromJson(Map<String, dynamic>.from(item)))
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
      weekOrDay: json['weekOrDay']?.toString() ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
    );
  }
}

class SpendCategory {
  final String categoryName;
  final double percentage;

  SpendCategory({required this.categoryName, required this.percentage});

  factory SpendCategory.fromJson(Map<String, dynamic> json) {
    return SpendCategory(
      categoryName: json['categoryName']?.toString() ?? '',
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }
}

class DepartmentSpend {
  final String departmentName;
  final double amount;
  final double progressRatio;

  DepartmentSpend({
    required this.departmentName,
    required this.amount,
    required this.progressRatio,
  });

  factory DepartmentSpend.fromJson(Map<String, dynamic> json) {
    return DepartmentSpend(
      departmentName: json['departmentName']?.toString() ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      progressRatio: (json['progressRatio'] ?? 0.0).toDouble(),
    );
  }
}
