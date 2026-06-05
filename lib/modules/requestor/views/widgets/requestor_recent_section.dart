import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/date_helper.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import 'package:cash/utils/mappers/expense_category_visuals.dart';
import 'package:cash/utils/mappers/request_status_visuals.dart';

/// Recent-requests list for the Requestor Dashboard.
///
/// Pure presentation — the parent supplies the list and the tap
/// callback. Renders byte-identical output to the previous inline
/// implementation. Extracted from `requestor_dashboard_view.dart` to
/// keep the parent under the 400-line target.
class RequestorRecentList extends StatelessWidget {
  final List items;
  final void Function(Map item) onTap;

  const RequestorRecentList({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final item = items[i] as Map;
        final purpose = (item['purpose'] ?? 'Request').toString();
        final status = (item['status'] ?? 'pending').toString();
        final category = (item['category'] ?? '').toString();
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final dateStr = DateHelper.formatDate(item['date']?.toString());

        final statusColor = RequestStatusVisuals.colorFor(status);
        final statusBg = RequestStatusVisuals.bgFor(status);
        final iconColor = ExpenseCategoryVisuals.colorFor(category);
        final iconBg = ExpenseCategoryVisuals.bgFor(category);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(16.r),
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            highlightColor: AppColors.primary.withValues(alpha: 0.04),
            child: Container(
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
                      ExpenseCategoryVisuals.iconFor(category),
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
                          purpose,
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
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.textSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${CurrencyFormatter.inr(amount)}',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          RequestStatusVisuals.labelFor(status),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RequestorRecentEmpty extends StatelessWidget {
  const RequestorRecentEmpty({super.key});

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
            'No recent requests',
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

class RequestorRecentError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const RequestorRecentError({
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

class RequestorRecentShimmer extends StatelessWidget {
  const RequestorRecentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Container(
            height: 72.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                SizedBox(width: 14.w),
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.purpleSurface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12.h,
                        width: 120.w,
                        decoration: BoxDecoration(
                          color: AppColors.purpleSurface
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 10.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.purpleSurface
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
