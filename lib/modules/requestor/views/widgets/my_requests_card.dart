import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/mappers/request_status_visuals.dart';
import 'package:cash/utils/mappers/expense_category_visuals.dart';
import '../../../../utils/app_colors.dart';

/// Single request row card for the Requestor "My Requests" list.
///
/// Renders the category icon, purpose, date + category line, amount, status
/// pill, optional "UNPAID" tag for approved-but-not-yet-paid items, and a
/// rejection reason banner when status is "rejected". Tapping the card
/// invokes [onTap] (typically `controller.viewDetails(req)`).
class MyRequestsCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onTap;

  const MyRequestsCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final req = request;
    final status = (req['status'] ?? 'pending').toString().toLowerCase();
    final purpose =
        (req['purpose'] ?? req['title'] ?? 'Request').toString();
    final date = (req['date'] ?? 'No Date').toString();
    final category =
        (req['category'] ?? _inferCategory(purpose)).toString();
    final amount = (req['amount'] as num?)?.toDouble() ?? 0.0;

    final statusColor = RequestStatusVisuals.colorFor(status);
    final statusBg = RequestStatusVisuals.bgFor(status);
    final statusText = RequestStatusVisuals.labelFor(status);
    final iconData = ExpenseCategoryVisuals.iconFor(purpose);
    final showUnpaidTag = _isApprovedUnpaid(req);

    return GestureDetector(
      onTap: onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category icon
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.purpleSurface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(iconData, color: AppColors.primary, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                // Info
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
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 11.sp, color: AppColors.textSlate),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              '$date • $category',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.textSlate,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Amount + status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (showUnpaidTag) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.amberBg,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 10.sp, color: AppColors.warningOrange),
                            SizedBox(width: 3.w),
                            Text(
                              'UNPAID',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warningOrange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // Rejection reason pill
            if (status == 'rejected') ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: AppColors.errorRed, size: 14.sp),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        (req['rejection_reason'] ??
                                'Missing information or receipt attachment')
                            .toString(),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _inferCategory(String purpose) {
    final p = purpose.toLowerCase();
    if (p.contains('food')) return 'Food';
    if (p.contains('travel') || p.contains('flight')) return 'Travel';
    if (p.contains('supplies')) return 'Inventory';
    return 'General';
  }

  /// True when the request is approved but the accountant has not yet
  /// settled payment — used to render the secondary "UNPAID" badge so the
  /// requestor can tell at a glance which approved items are still pending
  /// payout.
  ///
  /// Signals (any one is enough):
  ///   - `payment_status == 'unpaid' | 'pending'`
  ///   - status is `approved`/`auto_approved` AND no `payment_method` set
  bool _isApprovedUnpaid(Map<String, dynamic> req) {
    final status = (req['status'] ?? '').toString().toLowerCase();
    final paymentStatus =
        (req['payment_status'] ?? '').toString().toLowerCase();
    final paymentMethod =
        (req['payment_method'] ?? '').toString().trim().toLowerCase();
    final txnRef = (req['transaction_reference'] ?? '').toString().trim();

    // Don't show on non-approved states (rejected/pending/clarification).
    final isApprovedState =
        status == 'approved' || status == 'auto_approved' || status == 'unpaid';
    if (!isApprovedState) return false;

    // Already paid → hide.
    if (status == 'paid' ||
        paymentStatus == 'paid' ||
        paymentMethod.isNotEmpty ||
        txnRef.isNotEmpty) {
      return false;
    }

    // Approved + no payment trail → unpaid.
    return true;
  }
}
