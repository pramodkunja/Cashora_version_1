import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/app_colors.dart';

/// Hero block for Admin → Edit User: gradient avatar with accent ring,
/// user name, email, and an active/inactive status pill.
class AdminEditUserHero extends StatelessWidget {
  final String name;
  final String email;
  final bool isActive;

  const AdminEditUserHero({
    super.key,
    required this.name,
    required this.email,
    required this.isActive,
  });

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _green = AppColors.successGreen;

  @override
  Widget build(BuildContext context) {
    final Color avatarAccent = isActive
        ? AppColors.primary
        : AppColors.warningOrange;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 20.h),
      child: Column(
        children: [
          // Gradient avatar badge with accent ring
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: avatarAccent.withValues(alpha: 0.22),
                width: 1.4,
              ),
            ),
            child: Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive
                      ? [AppColors.primary, AppColors.primaryLight]
                      : [
                          AppColors.warningOrange,
                          AppColors.warningOrange.withValues(alpha: 0.75),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: avatarAccent.withValues(alpha: 0.35),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initialsOf(name),
                  style: GoogleFonts.outfit(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: _ink900,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 6.h),
          // Email + status pill
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              if (email.isNotEmpty)
                Text(
                  email,
                  style: GoogleFonts.inter(fontSize: 12.sp, color: _ink500),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? _green.withValues(alpha: 0.12)
                      : AppColors.warningOrange.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? Icons.check_circle_rounded
                          : Icons.block_rounded,
                      color: isActive ? _green : AppColors.warningOrange,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: isActive ? _green : AppColors.warningOrange,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initialsOf(String name) {
    if (name.isEmpty) return '?';
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
