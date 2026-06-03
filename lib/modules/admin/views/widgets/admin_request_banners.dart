import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/date_helper.dart';

/// Amber notice card shown on approved requests whose payment is still
/// pending (status=approved/auto_approved AND payment_status=pending).
/// Mirrors the small UNPAID pill on the approvals list cards.
class AdminUnpaidBanner extends StatelessWidget {
  const AdminUnpaidBanner({super.key});

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    const amberBg = Color(0xFFFEF3C7);
    const amberBorder = Color(0xFFFDE68A);
    const amberDark = Color(0xFF92400E);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: amberBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: amberBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payments_outlined, color: amber, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'UNPAID',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: amber,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Approved — awaiting payout by accountant',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: amberDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Red rejection-reason card shown above the body when a request was rejected.
/// Takes the rejection [reason] and the timestamp [whenStr] (raw — parsed by
/// `DateHelper.formatDateTime`).
class AdminRejectionCard extends StatelessWidget {
  final String reason;
  final String whenStr;

  const AdminRejectionCard({
    super.key,
    required this.reason,
    required this.whenStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFFECACA),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.format_quote_rounded,
                    size: 13.sp, color: const Color(0xFFB91C1C)),
              ),
              SizedBox(width: 10.w),
              Text(
                'REASON FOR REJECTION',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7F1D1D),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            reason,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.sp,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F1D1D),
            ),
          ),
          if (whenStr.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              '${AppText.noteFromApprover} • ${DateHelper.formatDateTime(whenStr, fallback: '—')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 11.sp,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
