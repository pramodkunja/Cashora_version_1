import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/date_helper.dart';

/// Status variant of the Admin Request Details screen used to localise
/// the action-row label in the details card (Approved on / Rejected on /
/// Updated).
enum AdminRequestDetailsVariant { pending, approved, rejected }

/// White rounded card with the textual details of a request: purpose,
/// description, submission date and (optionally) approval / rejection /
/// update date.
class AdminRequestDetailsInfoCard extends StatelessWidget {
  final String purpose;
  final String description;
  final String submittedAt;
  final String? actionAt;
  final AdminRequestDetailsVariant variant;

  const AdminRequestDetailsInfoCard({
    super.key,
    required this.purpose,
    required this.description,
    required this.submittedAt,
    required this.actionAt,
    required this.variant,
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
          if (actionAt != null) ...[
            _divider(),
            _kvRow(
              variant == AdminRequestDetailsVariant.rejected
                  ? 'Rejected on'
                  : variant == AdminRequestDetailsVariant.approved
                      ? 'Approved on'
                      : 'Updated',
              DateHelper.formatDateTime(actionAt!, fallback: '—'),
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
