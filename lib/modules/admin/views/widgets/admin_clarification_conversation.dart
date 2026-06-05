import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/date_helper.dart';

/// Clarification thread card showing the back-and-forth between the
/// approver and the requestor. Extracted from
/// `admin_clarification_status_view.dart` to keep the parent under the
/// 400-line target.
///
/// Pure presentation — the parent supplies the rx-resolved list and the
/// requestor name so the widget has no controller dependency.
class AdminClarificationConversation extends StatelessWidget {
  final List clarifications;
  final String requestorName;

  const AdminClarificationConversation({
    super.key,
    required this.clarifications,
    required this.requestorName,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint(
          '[Clarification][view] rxList size = ${clarifications.length}');
    }
    if (clarifications.isEmpty) {
      return _whiteCard(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Center(
          child: Text(
            'No clarification history yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSlate,
            ),
          ),
        ),
      );
    }

    return _whiteCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: clarifications.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final question = item['question']?.toString() ?? '';
          final response = item['response']?.toString() ?? '';
          final askedAt = item['asked_at']?.toString() ?? '';
          final respondedAtRaw = item['responded_at']?.toString() ?? '';
          final hasResponse =
              response.isNotEmpty && respondedAtRaw.isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(
              bottom: idx == clarifications.length - 1 ? 0 : 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (question.isNotEmpty)
                  _msg(
                    fromApprover: true,
                    text: question,
                    time: DateHelper.formatDateTime(askedAt,
                        fallback: AppText.recently),
                  ),
                if (hasResponse) ...[
                  SizedBox(height: 10.h),
                  _msg(
                    fromApprover: false,
                    text: response,
                    time: DateHelper.formatDateTime(respondedAtRaw,
                        fallback: AppText.recently),
                    label: requestorName,
                  ),
                ] else if (response.isEmpty) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14.r),
                          border:
                              Border.all(color: const Color(0xFFFEF3C7)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hourglass_top_rounded,
                                size: 10.sp,
                                color: const Color(0xFFB45309)),
                            SizedBox(width: 4.w),
                            Text(
                              'Waiting for response',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(18.w),
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
      child: child,
    );
  }

  Widget _msg({
    required bool fromApprover,
    required String text,
    required String time,
    String? label,
  }) {
    final bg = fromApprover ? AppColors.purpleSurface : AppColors.mintBg;
    final accent =
        fromApprover ? AppColors.primary : AppColors.successGreen;
    final headLabel =
        fromApprover ? AppText.youApprover : (label ?? 'Requestor');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          fromApprover ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: fromApprover
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    headLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    time,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.textSlate,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(fromApprover ? 4.r : 14.r),
                    topRight: Radius.circular(fromApprover ? 14.r : 4.r),
                    bottomLeft: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r),
                  ),
                ),
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
