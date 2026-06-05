import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import 'package:cash/utils/mappers/expense_category_visuals.dart';

/// Today's-transactions list for the Accountant Home screen.
///
/// Takes a list of typed transaction objects (each must expose
/// `.amount`, `.title`, `.subtitle`, `.iconType`). Extracted from
/// `accountant_home_view.dart` to keep the parent under 400 lines.
class AccountantHomeTransactionList extends StatelessWidget {
  final List transactions;

  const AccountantHomeTransactionList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final tx = transactions[i];
        final amount = (tx.amount as num).toDouble();
        final isExpense = amount < 0;
        final iconType = tx.iconType.toString().toLowerCase();
        final iconColor = ExpenseCategoryVisuals.colorFor(iconType);
        final iconBg = ExpenseCategoryVisuals.bgFor(iconType);

        return Container(
          padding: EdgeInsets.all(14.w),
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
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  ExpenseCategoryVisuals.iconFor(iconType),
                  color: iconColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      tx.subtitle.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.textSlate,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${isExpense ? '-' : '+'}₹${CurrencyFormatter.inr(amount.abs())}',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color:
                      isExpense ? AppColors.errorRed : AppColors.successGreen,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccountantHomeEmptyTransactions extends StatelessWidget {
  const AccountantHomeEmptyTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48.sp, color: AppColors.slate300),
          SizedBox(height: 12.h),
          Text(
            'No transactions today',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSlate,
            ),
          ),
        ],
      ),
    );
  }
}

class AccountantHomeErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AccountantHomeErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.redBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 36.sp, color: AppColors.errorRed),
          SizedBox(height: 8.h),
          Text(
            message,
            style:
                GoogleFonts.inter(fontSize: 13.sp, color: AppColors.errorRed),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry',
                style: GoogleFonts.inter(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
