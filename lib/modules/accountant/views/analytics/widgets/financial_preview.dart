import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../data/models/accountant_reports_model.dart';
import 'financial_preview_parts/financial_preview_categories.dart';
import 'financial_preview_parts/financial_preview_hero.dart';
import 'financial_preview_parts/financial_preview_transactions.dart';

/// Generated preview body for the Financial Reports screen — gradient
/// hero total card + top-categories breakdown + transaction list.
/// Extracted from `financial_reports_view.dart` to keep the parent under
/// the 400-line target.
///
/// Reuses [SpendSectionCard] from the sibling spend-analytics widgets
/// for the inner section cards (top categories + transactions list) so
/// the two analytics screens share their chrome.
class FinancialPreview extends StatelessWidget {
  final PreviewSummary summary;

  const FinancialPreview({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
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
    final maxCategoryTotal =
        topCategories.isEmpty ? 1.0 : topCategories.first.value;

    return Column(
      children: [
        FinancialPreviewHero(
          totalExpenses: summary.totalExpenses,
          monthYear: summary.monthYear,
          transactionCount: count,
          average: average,
          categoriesCount: byCategory.length,
        ),
        SizedBox(height: 16.h),
        if (topCategories.isNotEmpty)
          FinancialPreviewCategories(
            topCategories: topCategories,
            totalCategoryCount: byCategory.length,
            totalExpenses: summary.totalExpenses,
            maxCategoryTotal: maxCategoryTotal,
          ),
        if (topCategories.isNotEmpty) SizedBox(height: 16.h),
        FinancialPreviewTransactions(
          transactions: txns,
          categoryOrder: byCategory.keys.toList(),
        ),
      ],
    );
  }
}
