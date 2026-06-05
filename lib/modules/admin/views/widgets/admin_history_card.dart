import 'package:cash/utils/date_helper.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';

/// Single row card for the admin history list. Shows the request id + status
/// pill, requestor avatar + email + purpose + amount, submitted/action date
/// footer, and a clarification thread summary when applicable.
class AdminHistoryCard extends StatelessWidget {
  const AdminHistoryCard({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final status = (item['status']?.toString() ?? 'unknown').toLowerCase();
    final isApproved = status == 'approved' || status == 'auto_approved';
    final isRejected = status == 'rejected';
    final isClarification = status == 'clarification' ||
        status == 'clarification_responded';

    final statusColor = isApproved
        ? AppColors.successGreen
        : isRejected
            ? AppColors.errorRed
            : AppColors.warningOrange;
    final statusBg = isApproved
        ? AppColors.mintBg
        : isRejected
            ? AppColors.redBg
            : AppColors.amberBg;
    final statusIcon = isApproved
        ? Icons.check_circle_rounded
        : isRejected
            ? Icons.cancel_rounded
            : Icons.help_outline_rounded;
    final statusLabel = status == 'auto_approved'
        ? 'AUTO APPROVED'
        : isApproved
            ? 'APPROVED'
            : isRejected
                ? 'REJECTED'
                : 'CLARIFICATION';

    final requestId =
        item['request_id']?.toString() ?? item['id']?.toString() ?? 'N/A';
    final amount = (item['amount'] is num)
        ? (item['amount'] as num).toDouble()
        : double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;

    // ── Requestor — prefer the pre-built flat string the backend sends ─
    String userName = '';
    final flatName = item['requestor_name']?.toString().trim() ?? '';
    if (flatName.isNotEmpty) {
      userName = flatName;
    } else if (item['requestor'] is Map) {
      final r = item['requestor'];
      userName =
          '${r['first_name'] ?? ''} ${r['last_name'] ?? ''}'.trim();
      if (userName.isEmpty) userName = r['email']?.toString() ?? '';
    } else if (item['user'] != null) {
      userName = item['user'].toString();
    }
    if (userName.isEmpty) userName = 'Unknown';

    // ── Email — same fallback chain ────────────────────────────────────
    String email = item['requestor_email']?.toString() ?? '';
    if (email.isEmpty && item['requestor'] is Map) {
      email = item['requestor']['email']?.toString() ?? '';
    }

    final purpose = item['purpose']?.toString().trim().isNotEmpty == true
        ? item['purpose'].toString()
        : 'Expense Request';

    // ── Action timestamp — pick the field that matches the status ──────
    String actionRaw = '';
    String actionLabel = 'ACTION';
    if (isApproved && (item['approved_at']?.toString().isNotEmpty ?? false)) {
      actionRaw = item['approved_at'].toString();
      actionLabel = 'APPROVED';
    } else if (isRejected &&
        (item['rejected_at']?.toString().isNotEmpty ?? false)) {
      actionRaw = item['rejected_at'].toString();
      actionLabel = 'REJECTED';
    } else if (isClarification) {
      actionRaw = item['updated_at']?.toString() ?? '';
      actionLabel = 'LAST UPDATE';
    } else {
      actionRaw = item['updated_at']?.toString() ?? '';
      actionLabel = 'UPDATED';
    }
    final actionDate = DateHelper.formatDate(actionRaw);
    final submittedDate = DateHelper.formatDate(item['created_at']?.toString());

    // ── Clarification thread breakdown ─────────────────────────────────
    final clarifications = item['clarification_history'] is List
        ? List<Map<String, dynamic>>.from(item['clarification_history'])
        : <Map<String, dynamic>>[];
    final pendingClarifications = clarifications.where((c) {
      final r = c['response']?.toString().trim() ?? '';
      return r.isEmpty || r.toLowerCase() == 'null';
    }).length;

    return Container(
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
        children: [
          // ── Top row: REQUEST ID (left) + status pill (right) ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REQUEST ID',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSlate,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      requestId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 13.sp),
                    SizedBox(width: 5.w),
                    Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
          SizedBox(height: 12.h),

          // ── Requestor + amount row ───────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    _initials(userName),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: AppColors.textSlate,
                        ),
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Text(
                      purpose,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '₹${CurrencyFormatter.inr(amount)}',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
          SizedBox(height: 10.h),

          // ── Date footer: SUBMITTED | ACTION ───────────────────────────
          Row(
            children: [
              Expanded(
                child: _dateBlock(
                  label: 'SUBMITTED',
                  value: submittedDate,
                  alignEnd: false,
                ),
              ),
              Container(
                width: 1,
                height: 26.h,
                color: const Color(0xFFF1F5F9),
              ),
              Expanded(
                child: _dateBlock(
                  label: actionLabel,
                  value: actionDate,
                  alignEnd: true,
                ),
              ),
            ],
          ),

          // ── Clarification thread summary ─────────────────────────────
          if (isClarification && clarifications.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.purpleSurface,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    pendingClarifications > 0
                        ? Icons.help_outline_rounded
                        : Icons.mark_email_read_rounded,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      pendingClarifications > 0
                          ? '${clarifications.length} clarification${clarifications.length == 1 ? '' : 's'} · $pendingClarifications awaiting response'
                          : '${clarifications.length} clarification${clarifications.length == 1 ? '' : 's'} · all answered',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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

  Widget _dateBlock({
    required String label,
    required String value,
    required bool alignEnd,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSlate,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
