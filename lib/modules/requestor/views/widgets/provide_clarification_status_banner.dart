import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';

class ProvideClarificationStatusBanner extends StatelessWidget {
  const ProvideClarificationStatusBanner({
    super.key,
    required this.isPending,
    required this.isApproved,
    required this.isRejected,
  });

  final bool isPending;
  final bool isApproved;
  final bool isRejected;

  @override
  Widget build(BuildContext context) {
    late Color bg, color;
    late IconData icon;
    late String title, subtitle;

    if (isPending) {
      bg = AppColors.amberBg;
      color = AppColors.warningOrange;
      icon = Icons.priority_high_rounded;
      title = AppText.actionRequired;
      subtitle = AppText.approverRequestedClarification;
    } else if (isApproved) {
      bg = AppColors.mintBg;
      color = AppColors.successGreen;
      icon = Icons.check_circle_rounded;
      title = AppText.approved;
      subtitle = AppText.requestApproved;
    } else if (isRejected) {
      bg = AppColors.redBg;
      color = AppColors.errorRed;
      icon = Icons.cancel_rounded;
      title = AppText.rejected;
      subtitle = AppText.rejected;
    } else {
      bg = AppColors.purpleSurface;
      color = AppColors.primary;
      icon = Icons.mark_email_read_rounded;
      title = AppText.responseSent;
      subtitle = AppText.clarificationSubmittedWait;
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 16.sp, color: Colors.white),
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
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: color,
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
