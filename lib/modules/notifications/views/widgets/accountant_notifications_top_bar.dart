import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../../controllers/accountant_notifications_controller.dart';

class AccountantNotificationsTopBar extends StatelessWidget {
  const AccountantNotificationsTopBar({super.key, required this.controller});

  final AccountantNotificationsController controller;

  @override
  Widget build(BuildContext context) {
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
          _MarkAllReadPill(onTap: controller.markAllRead),
        ],
      ),
    );
  }
}

class _MarkAllReadPill extends StatelessWidget {
  const _MarkAllReadPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
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
}
