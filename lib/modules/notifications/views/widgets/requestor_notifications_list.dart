import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../../data/notification_model.dart';
import 'requestor_notifications_card.dart';

class RequestorNotificationsList extends StatelessWidget {
  const RequestorNotificationsList({
    super.key,
    required this.items,
    required this.emptySubtitle,
    required this.onItemTap,
  });

  final List<PushNotification> items;
  final String emptySubtitle;
  final ValueChanged<PushNotification> onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RequestorNotificationsEmptyState(subtitle: emptySubtitle);
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 24.h),
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => EntranceWrap(
        duration: Duration(milliseconds: 600 + (i * 60).clamp(0, 600)),
        child: RequestorNotificationsCard(
          item: items[i],
          onTap: () => onItemTap(items[i]),
        ),
      ),
    );
  }
}

class RequestorNotificationsEmptyState extends StatelessWidget {
  const RequestorNotificationsEmptyState({
    super.key,
    required this.subtitle,
  });

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
