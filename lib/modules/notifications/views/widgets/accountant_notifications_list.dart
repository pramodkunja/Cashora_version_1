import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../../data/notification_model.dart';

class AccountantNotificationsList extends StatelessWidget {
  const AccountantNotificationsList({
    super.key,
    required this.items,
    required this.emptySubtitle,
    required this.onTapItem,
  });

  final List<PushNotification> items;
  final String emptySubtitle;
  final void Function(PushNotification item) onTapItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _AccountantNotificationsEmptyState(subtitle: emptySubtitle);
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 24.h),
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => EntranceWrap(
        duration: Duration(milliseconds: 600 + (i * 60).clamp(0, 600)),
        child: _AccountantNotificationCard(
          item: items[i],
          onTap: () => onTapItem(items[i]),
        ),
      ),
    );
  }
}

class _AccountantNotificationsEmptyState extends StatelessWidget {
  const _AccountantNotificationsEmptyState({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const HeroBadge(
              icon: Icons.notifications_none_rounded,
              diameter: 84,
              iconSize: 36,
            ),
            SizedBox(height: 18.h),
            Text(
              'All caught up!',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: CashoraColors.ink900,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: CashoraColors.ink500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountantNotificationCard extends StatelessWidget {
  const _AccountantNotificationCard({required this.item, required this.onTap});

  final PushNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPending =
        item.eventType == NotificationEventType.expenseApproved;
    final isPaid = item.eventType == NotificationEventType.expensePaid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFFAF9FF),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: item.isRead
                  ? CashoraColors.ink200
                  : AppColors.primary.withValues(alpha: 0.25),
              width: item.isRead ? 1 : 1.3,
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
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: [
                        _MiniBadge(
                          label: item.eventType.label,
                          bg: item.eventType.badgeBg,
                          fg: item.eventType.badgeColor,
                        ),
                        if (isPending)
                          const _MiniBadge(
                            label: 'ACTION NEEDED',
                            bg: Color(0xFFFEF3C7),
                            fg: Color(0xFFF59E0B),
                          ),
                        if (isPaid)
                          const _MiniBadge(
                            label: 'SETTLED',
                            bg: Color(0xFFDCFCE7),
                            fg: Color(0xFF16A34A),
                          ),
                      ],
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

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
