import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../../data/notification_model.dart';

class RequestorNotificationsCard extends StatelessWidget {
  const RequestorNotificationsCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final PushNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActionRequired =
        item.eventType == NotificationEventType.clarificationRequired;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: item.isRead
                ? Colors.white
                : (isActionRequired
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFFAF9FF)),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isActionRequired
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.40)
                  : (item.isRead
                      ? CashoraColors.ink200
                      : AppColors.primary.withValues(alpha: 0.25)),
              width: isActionRequired || !item.isRead ? 1.3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 12.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: item.eventType.iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(item.eventType.icon,
                    color: item.eventType.iconColor, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: CashoraColors.ink900,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          item.timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: CashoraColors.ink500,
                          ),
                        ),
                      ],
                    ),
                    if (item.expenseRef != null) ...[
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: item.eventType.iconBg,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          item.expenseRef!,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: item.eventType.iconColor,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 5.h),
                    Text(
                      item.body,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: CashoraColors.ink500,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.only(left: 6.w, top: 4.h),
                  decoration: BoxDecoration(
                    color: item.eventType.iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
