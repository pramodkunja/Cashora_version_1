import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../routes/app_routes.dart';
import 'admin_user_success_variant.dart';

/// Variant-coloured gradient header (green for happy path, red for
/// deactivation) with a close button that returns to the user list.
class AdminUserSuccessHeader extends StatelessWidget {
  const AdminUserSuccessHeader({super.key, required this.variant});

  final AdminUserSuccessVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = adminUserSuccessGradientFor(variant);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 84.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.until(
                (r) => r.settings.name == AppRoutes.ADMIN_USER_LIST),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.close_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              adminUserSuccessHeaderTitleFor(variant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
