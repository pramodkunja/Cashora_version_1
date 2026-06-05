import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';

/// Hero summary card for the Requestor Dashboard.
///
/// Twin stat tiles (Spent + Pending) on top, full-width monthly limit
/// progress strip below. Mirrors the admin / accountant hero pattern so
/// flows feel cohesive. Pure presentation — rx access happens in the
/// parent Obx so this widget takes plain values + a callback for the
/// Pending tile.
class RequestorHeroCard extends StatelessWidget {
  final double amountSpent;
  final int pendingCount;
  final double monthlyLimit;
  final double progressRatio;
  final VoidCallback onPendingTap;

  const RequestorHeroCard({
    super.key,
    required this.amountSpent,
    required this.pendingCount,
    required this.monthlyLimit,
    required this.progressRatio,
    required this.onPendingTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = progressRatio.clamp(0.0, 1.0);
    final overLimit = ratio > 0.85;
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
                    icon: Icons.account_balance_wallet_rounded,
                    accent: AppColors.primary,
                    accentBg: AppColors.purpleSurface,
                    label: 'Spent',
                    value: '₹${CurrencyFormatter.inr(amountSpent)}',
                  ),
                ),
                Container(width: 1, height: 60.h, color: AppColors.slate100),
                Expanded(
                  child: _heroStatTile(
                    icon: Icons.hourglass_top_rounded,
                    accent: AppColors.warningOrange,
                    accentBg: AppColors.amberBg,
                    label: 'Pending',
                    value: pendingCount.toString(),
                    onTap: onPendingTap,
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
                colors: overLimit
                    ? [AppColors.redBg, const Color(0xFFFEF7F7)]
                    : [AppColors.purpleSurface, const Color(0xFFF7F5FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44.w,
                  height: 44.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 44.w,
                        height: 44.w,
                        child: CircularProgressIndicator(
                          value: ratio,
                          strokeWidth: 5.w,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            overLimit
                                ? AppColors.errorRed
                                : AppColors.primary,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${(ratio * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: overLimit
                              ? AppColors.errorRed
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MONTHLY LIMIT',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: overLimit
                              ? const Color(0xFF991B1B)
                              : const Color(0xFF4338CA),
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${CurrencyFormatter.inr(amountSpent)} of ₹${CurrencyFormatter.inr(monthlyLimit)}',
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.2,
                          ),
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
    VoidCallback? onTap,
  }) {
    final inner = Padding(
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
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return inner;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.04),
        child: inner,
      ),
    );
  }
}
