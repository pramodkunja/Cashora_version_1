import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../profile/controllers/settings_controller.dart';

class NotificationsView extends GetView<SettingsController> {
  const NotificationsView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: _purple, size: 18.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Manage push notifications for account activity.',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: _purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  _section('APPROVALS'),
                  SizedBox(height: 10.h),
                  _card([
                    Obx(() => _toggleItem(
                          icon: Icons.verified_user_rounded,
                          title: AppText.approvalStatusUpdates,
                          subtitle: AppText.approvalStatusDesc,
                          value: controller.rxNotifyApproval.value,
                          onChanged: (v) =>
                              controller.rxNotifyApproval.value = v,
                        )),
                    Divider(
                        height: 0, indent: 62.w, color: const Color(0xFFF1F5F9)),
                    Obx(() => _toggleItem(
                          icon: Icons.help_outline_rounded,
                          title: AppText.clarificationRequests,
                          subtitle: AppText.clarificationRequestsDesc,
                          value: controller.rxNotifyClarification.value,
                          onChanged: (v) =>
                              controller.rxNotifyClarification.value = v,
                        )),
                  ]),

                  SizedBox(height: 20.h),

                  _section('ACTIVITY'),
                  SizedBox(height: 10.h),
                  _card([
                    Obx(() => _toggleItem(
                          icon: Icons.note_add_rounded,
                          title: AppText.newRequestSubmitted,
                          subtitle: AppText.newRequestDesc,
                          value: controller.rxNotifyRequest.value,
                          onChanged: (v) =>
                              controller.rxNotifyRequest.value = v,
                        )),
                    Divider(
                        height: 0, indent: 62.w, color: const Color(0xFFF1F5F9)),
                    Obx(() => _toggleItem(
                          icon: Icons.access_time_rounded,
                          title: AppText.paymentReminders,
                          subtitle: AppText.paymentRemindersDesc,
                          value: controller.rxNotifyPayment.value,
                          onChanged: (v) =>
                              controller.rxNotifyPayment.value = v,
                        )),
                  ]),

                  SizedBox(height: 28.h),

                  Center(
                    child: Text(
                      'Email notifications can be managed separately\nin your Account Settings.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: _slate500,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
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
            AppText.notifications,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: _slate500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: _purple, size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _slate900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: _slate500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _purple,
          ),
        ],
      ),
    );
  }
}
