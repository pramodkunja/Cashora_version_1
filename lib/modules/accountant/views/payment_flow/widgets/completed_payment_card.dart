import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/app_text.dart';

/// Payment details card for the Completed Request Details screen.
///
/// Extracted from `completed_request_details_view.dart` to bring the
/// parent screen file under 400 lines. Renders byte-identical output to
/// the previous inline `_buildPaymentCard` implementation.
class CompletedPaymentCard extends StatelessWidget {
  final String method;
  final String transactionId;
  final String processedAt;
  final String approvedDate;
  final String requestDate;
  final String paymentDate;

  const CompletedPaymentCard({
    super.key,
    required this.method,
    required this.transactionId,
    required this.processedAt,
    this.approvedDate = '',
    this.requestDate = '',
    this.paymentDate = '',
  });

  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      icon: Icons.payments_rounded,
      title: AppText.paymentDetails,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(_paymentIcon(method),
                    color: AppColors.primary, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.paymentSource,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.textSlate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      method,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.mintBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 12.sp, color: AppColors.successGreen),
                    SizedBox(width: 4.w),
                    Text(
                      'PAID',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _txnRow('UTR / Txn ID', transactionId, mono: true),
                if (requestDate.isNotEmpty && requestDate != '---') ...[
                  SizedBox(height: 10.h),
                  _txnRow('Requested On', requestDate),
                ],
                if (approvedDate.isNotEmpty && approvedDate != '---') ...[
                  SizedBox(height: 10.h),
                  _txnRow('Approved On', approvedDate),
                ],
                if (paymentDate.isNotEmpty && paymentDate != '---') ...[
                  SizedBox(height: 10.h),
                  _txnRow('Paid On', paymentDate),
                ],
                SizedBox(height: 10.h),
                _txnRow('Processed At', processedAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

  Widget _txnRow(String label, String value, {bool mono = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: (mono ? GoogleFonts.robotoMono : GoogleFonts.inter)(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  IconData _paymentIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('upi')) return Icons.qr_code_2_rounded;
    if (m.contains('cash')) return Icons.payments_rounded;
    if (m.contains('cheque')) return Icons.receipt_long_rounded;
    if (m.contains('neft') || m.contains('rtgs') || m.contains('imps')) {
      return Icons.account_balance_rounded;
    }
    if (m.contains('bank')) return Icons.account_balance_rounded;
    return Icons.account_balance_wallet_rounded;
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
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
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}
