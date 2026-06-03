import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../controllers/admin_notifications_controller.dart';
import '../data/notification_model.dart';

class AdminNotificationView extends GetView<AdminNotificationsController> {
  const AdminNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminNotificationsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: CashoraColors.bgB,
        body: Stack(
          children: [
            const AppBackground(extraBloom: true),
            SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  _buildTopBar(),
                  SizedBox(height: 8.h),
                  _buildTabBar(),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: Obx(
                      () => TabBarView(
                        children: [
                          _buildList(controller.allNotifications,
                              emptySubtitle:
                                  'Updates will appear here as they arrive.'),
                          _buildList(controller.clarifications,
                              emptySubtitle:
                                  'Clarification updates will show up here.'),
                          _buildList(controller.decisions,
                              emptySubtitle:
                                  'Approve / reject decisions land here.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          CircleIconButton(
              icon: Icons.arrow_back_rounded, onTap: () => Get.back()),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: CashoraColors.ink900,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Obx(() {
                    final unread = controller.notifications
                        .where((n) => !n.isRead)
                        .length;
                    if (unread == 0) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        '$unread unread',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          _markAllReadPill(),
        ],
      ),
    );
  }

  Widget _markAllReadPill() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: controller.markAllRead,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.done_all_rounded,
                  color: AppColors.primary, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                'Mark all',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: CashoraColors.ink200),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: CashoraColors.ink500,
        labelStyle:
            GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w500),
        labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Clarifications'),
          Tab(text: 'Decisions'),
        ],
      ),
    );
  }

  Widget _buildList(List<PushNotification> items,
      {required String emptySubtitle}) {
    if (items.isEmpty) return _emptyState(emptySubtitle);
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 24.h),
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => EntranceWrap(
        duration: Duration(milliseconds: 600 + (i * 60).clamp(0, 600)),
        child: _buildNotificationCard(items[i]),
      ),
    );
  }

  Widget _emptyState(String subtitle) {
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

  Widget _buildNotificationCard(PushNotification item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.markRead(item.id);
          _navigateToExpense(item);
        },
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
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: item.eventType.badgeBg,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        item.eventType.label.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: item.eventType.badgeColor,
                          letterSpacing: 0.6,
                        ),
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

  void _navigateToExpense(PushNotification item) {
    final args = <String, dynamic>{
      'expense_id': item.expenseId,
      'request_id': item.requestId,
      'from_notification': true,
    };
    Get.toNamed('/admin/request-details', arguments: args);
  }
}
