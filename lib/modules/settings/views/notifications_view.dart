import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../../profile/controllers/settings_controller.dart';

class NotificationsView extends GetView<SettingsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: CashoraColors.bgB,
      body: Stack(
        children: [
          const AppBackground(extraBloom: true),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                AppTopBar(
                    title: AppText.notifications,
                    onBack: () => Get.back()),
                Expanded(
                  child: WhiteSheet(
                    bottomInset: bottomInset,
                    padding:
                        const EdgeInsets.fromLTRB(22, 14, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EntranceWrap(
                          duration: const Duration(milliseconds: 600),
                          child: _infoBanner(
                            icon: Icons.info_outline_rounded,
                            text:
                                'Manage push notifications for account activity.',
                          ),
                        ),
                        SizedBox(height: 22.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 750),
                          child: const SectionHeader(
                            icon: Icons.verified_user_outlined,
                            title: 'Approvals',
                          ),
                        ),
                        SizedBox(height: 10.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 850),
                          child: _toggleCard([
                            Obx(() => _toggleItem(
                                  icon: Icons.verified_user_rounded,
                                  title: AppText.approvalStatusUpdates,
                                  subtitle: AppText.approvalStatusDesc,
                                  value: controller.rxNotifyApproval.value,
                                  onChanged: (v) =>
                                      controller.rxNotifyApproval.value = v,
                                )),
                            _divider(),
                            Obx(() => _toggleItem(
                                  icon: Icons.help_outline_rounded,
                                  title: AppText.clarificationRequests,
                                  subtitle:
                                      AppText.clarificationRequestsDesc,
                                  value:
                                      controller.rxNotifyClarification.value,
                                  onChanged: (v) => controller
                                      .rxNotifyClarification.value = v,
                                )),
                          ]),
                        ),
                        SizedBox(height: 22.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 950),
                          child: const SectionHeader(
                            icon: Icons.bolt_outlined,
                            title: 'Activity',
                          ),
                        ),
                        SizedBox(height: 10.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 1050),
                          child: _toggleCard([
                            Obx(() => _toggleItem(
                                  icon: Icons.note_add_rounded,
                                  title: AppText.newRequestSubmitted,
                                  subtitle: AppText.newRequestDesc,
                                  value: controller.rxNotifyRequest.value,
                                  onChanged: (v) =>
                                      controller.rxNotifyRequest.value = v,
                                )),
                            _divider(),
                            Obx(() => _toggleItem(
                                  icon: Icons.access_time_rounded,
                                  title: AppText.paymentReminders,
                                  subtitle: AppText.paymentRemindersDesc,
                                  value: controller.rxNotifyPayment.value,
                                  onChanged: (v) =>
                                      controller.rxNotifyPayment.value = v,
                                )),
                          ]),
                        ),
                        SizedBox(height: 28.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 1150),
                          child: Center(
                            child: Text(
                              'Email notifications can be managed separately\nin your Account Settings.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: CashoraColors.ink500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: CashoraColors.ink200),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() =>
      Divider(height: 0, indent: 62.w, color: CashoraColors.ink200);

  Widget _toggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18.sp),
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
                    fontWeight: FontWeight.w700,
                    color: CashoraColors.ink900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: CashoraColors.ink500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
