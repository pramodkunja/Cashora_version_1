import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../data/models/accountant_reports_model.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/mappers/expense_category_visuals.dart';
import '../spend_section_helpers.dart';
import 'financial_preview_formatters.dart';

/// Transactions list card — count chip in the header, empty-state for an
/// empty list, otherwise a vertical stack of category-tinted rows.
class FinancialPreviewTransactions extends StatelessWidget {
  final List<TransactionRow> transactions;
  final List<String> categoryOrder;

  const FinancialPreviewTransactions({
    super.key,
    required this.transactions,
    required this.categoryOrder,
  });

  @override
  Widget build(BuildContext context) {
    final count = transactions.length;
    return SpendSectionCard(
      icon: Icons.receipt_long_rounded,
      title: 'Transactions',
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: AppColors.purpleSurface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          '$count',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      child: transactions.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 28.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 36.sp, color: AppColors.slate300),
                    SizedBox(height: 8.h),
                    Text(
                      'No transactions in this period',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSlate,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: transactions.asMap().entries.map((entry) {
                final i = entry.key;
                final t = entry.value;
                final color = FinancialPreviewFormatters.categoryColors[
                    categoryOrder.indexOf(t.category) %
                        FinancialPreviewFormatters.categoryColors.length];
                return _TransactionRowTile(
                  transaction: t,
                  color: color,
                  isLast: i == transactions.length - 1,
                );
              }).toList(),
            ),
    );
  }
}

class _TransactionRowTile extends StatelessWidget {
  final TransactionRow transaction;
  final Color color;
  final bool isLast;

  const _TransactionRowTile({
    required this.transaction,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                ExpenseCategoryVisuals.iconFor(transaction.category),
                color: color,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FinancialPreviewFormatters.prettyCategory(
                        transaction.category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    FinancialPreviewFormatters.formatReadableDate(
                        transaction.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textSlate,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '₹${FinancialPreviewFormatters.formatMoney(transaction.amount)}',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
