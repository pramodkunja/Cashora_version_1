import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/profile_controller.dart';
import 'profile_card.dart';

class ProfileInfoCard extends StatelessWidget {
  final ProfileController controller;

  const ProfileInfoCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ProfileCard(children: [
        _infoRow(Icons.business_rounded, 'Organization',
            controller.rxOrgName.value),
        _infoRow(Icons.qr_code_rounded, 'Org Code',
            controller.rxOrgCode.value),
        _infoRow(Icons.phone_rounded, AppText.phone, controller.rxPhone.value),
        _infoRow(Icons.badge_rounded, AppText.role, controller.rxRole.value),
        if (controller.rxDepartmentName.value.isNotEmpty)
          _infoRow(Icons.business_rounded, 'Department',
              controller.rxDepartmentName.value),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: AppColors.purpleSurface,
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
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSlate,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value.isEmpty ? '-' : value,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
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
