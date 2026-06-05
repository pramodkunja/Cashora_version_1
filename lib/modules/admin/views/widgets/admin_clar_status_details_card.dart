import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/date_helper.dart';

/// White card listing purpose, description, and submission timestamps for the
/// clarification status view.
class AdminClarStatusDetailsCard extends StatelessWidget {
  final String purpose;
  final String description;
  final String submittedAt;
  final String? updatedAt;

  const AdminClarStatusDetailsCard({
    super.key,
    required this.purpose,
    required this.description,
    required this.submittedAt,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kvRow('Purpose', purpose, multiline: true),
          if (description.isNotEmpty && description != purpose) ...[
            _divider(),
            _kvRow('Description', description, multiline: true),
          ],
          _divider(),
          _kvRow(
            'Submitted',
            DateHelper.formatDateTime(submittedAt, fallback: '—'),
          ),
          if (updatedAt != null) ...[
            _divider(),
            _kvRow(
              'Last update',
              DateHelper.formatDateTime(updatedAt!, fallback: '—'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kvRow(String label, String value, {bool multiline = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.sp,
                color: AppColors.textSlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              maxLines: multiline ? null : 2,
              overflow: multiline ? null : TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: const Color(0xFFF1F5F9));
}
