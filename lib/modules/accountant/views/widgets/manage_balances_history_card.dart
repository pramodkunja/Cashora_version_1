import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import '../../../../utils/date_helper.dart';
import '../../controllers/manage_balances_controller.dart';

/// Balance history card.
///
/// Handles loading skeleton, empty state and the rendered list of
/// historical balance entries.
class ManageBalancesHistoryCard extends StatelessWidget {
  const ManageBalancesHistoryCard({super.key, required this.controller});

  final ManageBalancesController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isHistoryLoading.value && controller.history.isEmpty) {
      return Container(
        padding: EdgeInsets.all(18.w),
        decoration: _cardDecoration(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (controller.history.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: _cardDecoration(),
        child: Center(
          child: Text(
            'No balance history yet',
            style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSlate),
          ),
        ),
      );
    }
    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: controller.history.asMap().entries.map((e) {
          final isLast = e.key == controller.history.length - 1;
          return Column(
            children: [
              _historyRow(e.value),
              if (!isLast) Container(height: 1, color: AppColors.slate100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _historyRow(Map<String, dynamic> item) {
    final date = item['date']?.toString() ?? '';
    final opening = (item['opening_balance'] as num?)?.toDouble() ?? 0;
    final closing = (item['closing_balance'] as num?)?.toDouble() ?? 0;
    final delta = closing - opening;
    final updatedBy = item['updated_by']?.toString() ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDFF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateHelper.formatDateTime(date, fallback: date).split(',').first,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (updatedBy.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Updated by $updatedBy',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textSlate,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${CurrencyFormatter.inr(closing)}',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${delta >= 0 ? '+' : ''}₹${CurrencyFormatter.inr(delta.abs())}',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: delta >= 0 ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
            ],
          ),
        ],
      ),
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
