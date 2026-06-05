import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import '../../controllers/manage_balances_controller.dart';

/// Current-day balance snapshot card.
///
/// Shows opening / closing big stats, an in/out row and an optional note.
class ManageBalancesSummaryCard extends StatelessWidget {
  const ManageBalancesSummaryCard({super.key, required this.controller});

  final ManageBalancesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _bigStat(
                  label: 'OPENING',
                  value: controller.openingBalance.value,
                  color: AppColors.primary,
                ),
              ),
              Container(width: 1, height: 56.h, color: AppColors.slate100),
              Expanded(
                child: _bigStat(
                  label: 'CLOSING',
                  value: controller.closingBalance.value,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(height: 1, color: AppColors.slate100),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  icon: Icons.south_west_rounded,
                  label: 'In',
                  value: controller.amountIn.value,
                  color: AppColors.successGreen,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _miniStat(
                  icon: Icons.north_east_rounded,
                  label: 'Out',
                  value: controller.amountOut.value,
                  color: AppColors.warningOrange,
                ),
              ),
            ],
          ),
          if (controller.note.value.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFFEF3C7)),
              ),
              child: Row(
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 14.sp, color: const Color(0xFFB45309)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      controller.note.value,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bigStat({
    required String label,
    required double value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSlate,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${CurrencyFormatter.inr(value)}',
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 14.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: AppColors.textSlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '₹${CurrencyFormatter.inr(value)}',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12.r,
          offset: Offset(0, 3.h),
        ),
      ],
    );
  }
}
