import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/requestor_notifications_controller.dart';
import '../data/notification_model.dart';

class RequestorNotificationView
    extends GetView<RequestorNotificationsController> {
  const RequestorNotificationView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _amber = AppColors.warningOrange;
  static const _amberBg = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    Get.put(RequestorNotificationsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: Obx(
                () => TabBarView(
                  children: [
                    _buildList(controller.allNotifications),
                    _buildList(controller.actionRequired),
                    _buildList(controller.approved),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        22.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Notifications',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: controller.markAllRead,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Mark all read',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
      height: 38.h,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          color: _purple,
          borderRadius: BorderRadius.circular(100.r),
        ),
        indicatorPadding:
            EdgeInsets.symmetric(horizontal: -14.w, vertical: 4.h),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: _slate500,
        labelStyle:
            GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w500),
        labelPadding: EdgeInsets.symmetric(horizontal: 18.w),
        overlayColor:
            WidgetStateProperty.all(_purple.withOpacity(0.06)),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Action Required'),
          Tab(text: 'Approved'),
        ],
      ),
    );
  }

  Widget _buildList(List<NotificationItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 56.sp, color: _slate300),
            SizedBox(height: 12.h),
            Text(
              'No notifications',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _slate500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 24.h),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final item = items[i];
        if (item.title == 'Clarification Needed') {
          return _buildClarificationCard(item);
        }
        return _buildNotificationItem(item);
      },
    );
  }

  Widget _buildClarificationCard(NotificationItem item) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _amberBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.priority_high_rounded,
                    color: _amber, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: _slate900,
                            ),
                          ),
                        ),
                        Text(
                          item.time,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: _slate500,
                          ),
                        ),
                      ],
                    ),
                    if (item.ref != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        item.ref!,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: _slate500,
                        ),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Text(
                      item.body ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: _slate900,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isUrgent)
                Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.only(left: 6.w, top: 4.h),
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.upload_file_rounded, size: 16.sp),
              label: Text(
                'Upload Receipt',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _amber,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem item) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              item.icon ?? Icons.notifications_rounded,
              color: _purple,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: _slate900,
                        ),
                      ),
                    ),
                    Text(
                      item.time,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: _slate500,
                      ),
                    ),
                  ],
                ),
                if (item.ref != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    item.ref!,
                    style: GoogleFonts.inter(
                        fontSize: 11.sp, color: _slate500),
                  ),
                ],
                SizedBox(height: 4.h),
                if (item.amount != null &&
                    item.body != null &&
                    item.body!.contains('sent to'))
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: _slate500,
                      ),
                      children: [
                        TextSpan(
                          text: item.amount,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: _slate900,
                          ),
                        ),
                        TextSpan(text: ' ${item.body}'),
                      ],
                    ),
                  )
                else
                  Text(
                    item.body ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: _slate500,
                      height: 1.4,
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
