import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';

/// Summary hero card for the "Today's Transactions" screen.
///
/// Two stat tiles (Cash In / Cash Out) over a colored NET strip that
/// turns green when positive, red when negative. Pure presentation —
/// rx access happens in the parent Obx so this widget takes plain
/// doubles.
class CashFlowHeroCard extends StatelessWidget {
  final double totalIn;
  final double totalOut;
  final double net;

  const CashFlowHeroCard({
    super.key,
    required this.totalIn,
    required this.totalOut,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    final positive = net >= 0;
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
                    icon: Icons.arrow_downward_rounded,
                    accent: AppColors.successGreen,
                    accentBg: AppColors.mintBg,
                    label: 'CASH IN',
                    value: '₹${CurrencyFormatter.inr(totalIn)}',
                  ),
                ),
                Container(width: 1, height: 60.h, color: AppColors.slate100),
                Expanded(
                  child: _heroStatTile(
                    icon: Icons.arrow_upward_rounded,
                    accent: AppColors.errorRed,
                    accentBg: AppColors.redBg,
                    label: 'CASH OUT',
                    value: '₹${CurrencyFormatter.inr(totalOut)}',
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
                colors: positive
                    ? [AppColors.mintBg, const Color(0xFFF0FDF4)]
                    : [AppColors.redBg, const Color(0xFFFEF7F7)],
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
                        color: Color(0x141E293B),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    positive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color:
                        positive ? AppColors.successGreen : AppColors.errorRed,
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
                        'NET TODAY',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: positive
                              ? const Color(0xFF047857)
                              : const Color(0xFF991B1B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${positive ? '+' : '-'}₹${CurrencyFormatter.inr(net.abs())}',
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: positive
                                ? const Color(0xFF064E3B)
                                : const Color(0xFF7F1D1D),
                            letterSpacing: -0.3,
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
            label,
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
