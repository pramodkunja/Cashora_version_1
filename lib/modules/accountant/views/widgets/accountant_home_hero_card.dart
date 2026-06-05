import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/app_text.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';

/// Summary hero card for the Accountant Home screen.
///
/// Twin balance tiles (Open + Closing) on top, full-width IN HAND CASH
/// strip below with a growth pill on the right. Extracted from
/// `accountant_home_view.dart` to keep the parent under 400 lines.
class AccountantHomeHeroCard extends StatelessWidget {
  final double open;
  final double closing;
  final double inHand;
  final String growth;

  const AccountantHomeHeroCard({
    super.key,
    required this.open,
    required this.closing,
    required this.inHand,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = growth.trim().startsWith('+') ||
        (!growth.contains('-') && growth.isNotEmpty);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B45B0).withValues(alpha: 0.12),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: _heroStatTile(
                    icon: Icons.lock_clock_rounded,
                    accent: AppColors.primary,
                    accentBg: AppColors.purpleSurface,
                    label: AppText.openBalance,
                    value: '₹${CurrencyFormatter.inr(open)}',
                  ),
                ),
                Container(width: 1, height: 60.h, color: AppColors.slate100),
                Expanded(
                  child: _heroStatTile(
                    icon: Icons.lock_rounded,
                    accent: AppColors.primary,
                    accentBg: AppColors.purpleSurface,
                    label: AppText.closingBalance,
                    value: '₹${CurrencyFormatter.inr(closing)}',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(22.r),
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.mintBg,
                  const Color(0xFFF0FDF4),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1410B981),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.successGreen,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'IN HAND CASH',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF047857),
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${CurrencyFormatter.inr(inHand)}',
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF064E3B),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (growth.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 12.sp,
                          color: isPositive
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          growth,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: isPositive
                                ? AppColors.successGreen
                                : AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStatTile({
    required IconData icon,
    required Color accent,
    required Color accentBg,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accent, size: 18.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSlate,
              letterSpacing: 0.7,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.1,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
