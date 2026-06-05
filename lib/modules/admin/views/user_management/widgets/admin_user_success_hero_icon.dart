import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'admin_user_success_variant.dart';

/// Floating circular icon disc that overlaps the gradient header.
class AdminUserSuccessHeroIcon extends StatelessWidget {
  const AdminUserSuccessHeroIcon({super.key, required this.variant});

  final AdminUserSuccessVariant variant;

  @override
  Widget build(BuildContext context) {
    final accent = adminUserSuccessAccentFor(variant);
    final icon = switch (variant) {
      AdminUserSuccessVariant.create => Icons.person_add_alt_1_rounded,
      AdminUserSuccessVariant.update => Icons.verified_user_rounded,
      AdminUserSuccessVariant.activate => Icons.check_circle_rounded,
      AdminUserSuccessVariant.deactivate => Icons.person_off_rounded,
    };
    return Container(
      width: 96.w,
      height: 96.w,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 76.w,
          height: 76.w,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 38.sp),
        ),
      ),
    );
  }
}
