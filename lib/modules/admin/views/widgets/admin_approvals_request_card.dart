import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cash/utils/mappers/request_status_visuals.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../utils/request_mapper.dart';

/// Individual request card row used inside the admin approvals tab
/// lists. Renders the title, requester, department, amount, status
/// pill and (when applicable) an UNPAID tag for approved-but-unpaid
/// requests.
class AdminApprovalsRequestCard extends StatelessWidget {
  const AdminApprovalsRequestCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title =
        (item['title'] ?? item['purpose'] ?? AppText.unnamedRequest).toString();
    final user = RequestMapper.getUserName(item);
    final amount = (item['amount'] is num)
        ? (item['amount'] as num).toDouble()
        : double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;
    final department = RequestMapper.getDepartment(item);
    final rawStatus = (item['status'] ?? 'pending').toString().toLowerCase();
    final dateStr = RequestMapper.formatDate(item['date'] ?? item['created_at']);

    final statusColor = RequestStatusVisuals.colorFor(rawStatus);
    final statusBg = RequestStatusVisuals.bgFor(rawStatus);
    final statusLabel = RequestStatusVisuals.labelFor(rawStatus);

    // Show an UNPAID tag when an approved request still has the payment
    // outstanding (status=approved/auto_approved AND payment_status=pending).
    final paymentStatus =
        item['payment_status']?.toString().toLowerCase() ?? '';
    final isApprovedStatus =
        rawStatus == 'approved' || rawStatus == 'auto_approved';
    final showUnpaidTag =
        isApprovedStatus && paymentStatus == 'pending';

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
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.purpleSurface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: AppColors.primary, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
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
                          Icon(Icons.apartment_rounded,
                              size: 11.sp, color: AppColors.textSlate),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              department,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        statusLabel,
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
                          border: Border.all(
                            color: AppColors.warningOrange.withValues(alpha: 0.35),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.payments_outlined,
                                size: 9.sp, color: AppColors.warningOrange),
                            SizedBox(width: 3.w),
                            Text(
                              'UNPAID',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.warningOrange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSlate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
            SizedBox(height: 12.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundColor: AppColors.purpleSurface,
                  child: Text(
                    RequestMapper.getInitials(user),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requested by',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: AppColors.textSlate,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        user,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
