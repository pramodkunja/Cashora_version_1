import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/date_helper.dart';

class ProvideClarificationConversation extends StatelessWidget {
  const ProvideClarificationConversation({
    super.key,
    required this.request,
  });

  final Map request;

  String _formatDate(String dateStr) =>
      DateHelper.formatDateTime(dateStr, fallback: AppText.recently);

  @override
  Widget build(BuildContext context) {
    final raw = request['clarifications'];
    final List<Map<String, dynamic>> items = [];
    if (raw is List) {
      for (final it in raw) {
        if (it is Map) items.add(Map<String, dynamic>.from(it));
      }
    }

    if (items.isEmpty) {
      final adminComment = request['admin_remarks'] ?? request['comments'];
      if (adminComment != null && adminComment.toString().isNotEmpty) {
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: _ClarificationBubble(
            isApprover: true,
            text: adminComment.toString(),
            time: AppText.recently,
          ),
        );
      }
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            'No clarification history yet',
            style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSlate),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          final question = item['question']?.toString() ?? '';
          final response = item['response']?.toString() ?? '';
          final askedAt = _formatDate(item['asked_at']?.toString() ?? '');
          final respondedAt =
              _formatDate(item['responded_at']?.toString() ?? '');
          return Column(
            children: [
              if (question.isNotEmpty)
                _ClarificationBubble(
                    isApprover: true, text: question, time: askedAt),
              if (response.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _ClarificationBubble(
                    isApprover: false, text: response, time: respondedAt),
              ],
              SizedBox(height: 10.h),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ClarificationBubble extends StatelessWidget {
  const _ClarificationBubble({
    required this.isApprover,
    required this.text,
    required this.time,
  });

  final bool isApprover;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    final bg = isApprover ? AppColors.purpleSurface : AppColors.mintBg;
    final color = isApprover ? AppColors.primary : AppColors.successGreen;
    final label = isApprover ? AppText.approver : 'You';
    final icon = isApprover ? Icons.support_agent_rounded : Icons.person_rounded;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          isApprover ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isApprover) _avatar(icon, color, bg),
        if (isApprover) SizedBox(width: 8.w),
        Flexible(
          child: Column(
            crossAxisAlignment:
                isApprover ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: AppColors.textSlate,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isApprover ? 4.r : 14.r),
                    topRight: Radius.circular(isApprover ? 14.r : 4.r),
                    bottomLeft: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r),
                  ),
                ),
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isApprover) SizedBox(width: 8.w),
        if (!isApprover) _avatar(icon, color, bg),
      ],
    );
  }

  Widget _avatar(IconData icon, Color color, Color bg) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 16.sp, color: color),
    );
  }
}
