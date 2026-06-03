import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/date_helper.dart';

/// Timeline card for the Admin Request Details screen.
///
/// Shows up to two rows — "Approved" (if [updatedAt] is non-null) and
/// "Request submitted" — connected by a vertical divider. Extracted from
/// `admin_request_details_view.dart` to keep the parent screen under the
/// 400-line target; renders byte-identical output.
class AdminTimelineCard extends StatelessWidget {
  final String createdAt;
  final String? updatedAt;

  const AdminTimelineCard({
    super.key,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final hasApprovalRow = updatedAt != null;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          if (hasApprovalRow) ...[
            _timelineRow(
              icon: Icons.check_rounded,
              iconBg: const Color(0xFF10B981),
              title: 'Approved',
              subtitle: DateHelper.formatDateTime(updatedAt, fallback: '—'),
              highlight: true,
            ),
            _timelineConnector(),
          ],
          _timelineRow(
            icon: Icons.send_rounded,
            iconBg: AppColors.primaryBlue,
            title: 'Request submitted',
            subtitle: DateHelper.formatDateTime(createdAt, fallback: '—'),
            highlight: !hasApprovalRow,
          ),
        ],
      ),
    );
  }

  Widget _timelineRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 16.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: highlight ? iconBg : AppColors.textDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.textSlate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timelineConnector() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Container(width: 2, height: 22.h, color: const Color(0xFFE2E8F0)),
        ],
      ),
    );
  }
}
