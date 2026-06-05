import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/app_text.dart';
import 'financial_preview_formatters.dart';

/// Gradient hero amount card showing total expenses, the month chip and
/// the three quick stats (transactions / average / categories).
class FinancialPreviewHero extends StatelessWidget {
  final double totalExpenses;
  final String monthYear;
  final int transactionCount;
  final double average;
  final int categoriesCount;

  const FinancialPreviewHero({
    super.key,
    required this.totalExpenses,
    required this.monthYear,
    required this.transactionCount,
    required this.average,
    required this.categoriesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: AppColors.primary.withValues(alpha: 0.25),
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
                  color: Colors.white.withValues(alpha: 0.18),
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
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (monthYear.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    monthYear,
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
              '₹${FinancialPreviewFormatters.formatMoney(totalExpenses)}',
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
                child: _HeroStat(
                  label: 'Transactions',
                  value: '$transactionCount',
                  icon: Icons.receipt_long_rounded,
                ),
              ),
              Container(
                  width: 1,
                  height: 36.h,
                  color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: _HeroStat(
                  label: 'Average',
                  value: '₹${FinancialPreviewFormatters.formatMoney(average)}',
                  icon: Icons.trending_up_rounded,
                ),
              ),
              Container(
                  width: 1,
                  height: 36.h,
                  color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: _HeroStat(
                  label: 'Categories',
                  value: '$categoriesCount',
                  icon: Icons.category_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12.sp, color: Colors.white.withValues(alpha: 0.8)),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 0.6,
                ),
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
            maxLines: 1,
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
}
