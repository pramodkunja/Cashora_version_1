import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import '../../../../../routes/app_routes.dart';

/// Primary CTA: returns to the manage-users list by popping back to it.
class AdminUserSuccessPrimaryCta extends StatelessWidget {
  const AdminUserSuccessPrimaryCta({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: () => Get.until(
          (route) => route.settings.name == AppRoutes.ADMIN_USER_LIST,
        ),
        icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
        label: Text(
          AppText.goToManageUsers,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

/// Secondary CTA shown only on the create variant — pops back to the
/// add user form to add another user.
class AdminUserSuccessSecondaryCta extends StatelessWidget {
  const AdminUserSuccessSecondaryCta({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: () => Get.back(),
        icon: Icon(Icons.person_add_rounded,
            color: AppColors.primary, size: 18.sp),
        label: Text(
          AppText.addAnotherUser,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.purpleSurface,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
