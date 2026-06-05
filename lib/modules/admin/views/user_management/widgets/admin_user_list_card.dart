import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/app_colors.dart';

class AdminUserListCard extends StatelessWidget {
  const AdminUserListCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  final Map<String, dynamic> user;
  final VoidCallback onTap;

  static const Color _bgB = Color(0xFFF8F7FF);
  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    String name = user['full_name'] ??
        user['name'] ??
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    if (name.isEmpty) name = 'Unknown User';

    final role = user['role']?.toString() ?? 'Requestor';
    final email = user['email']?.toString() ?? 'No email';
    final isActive = user['isActive'] ?? user['is_active'] ?? true;

    final dept = user['department'];
    String? deptName;
    if (dept is Map && dept['name'] != null) {
      deptName = dept['name'].toString();
    }

    // Role colors
    Color rolePillBg;
    Color rolePillFg;
    switch (role.toLowerCase()) {
      case 'accountant':
        rolePillBg = const Color(0xFFEFF6FF);
        rolePillFg = const Color(0xFF2563EB);
        break;
      case 'admin':
      case 'super_admin':
        rolePillBg = AppColors.primary.withValues(alpha: 0.10);
        rolePillFg = AppColors.primary;
        break;
      default:
        rolePillBg = const Color(0xFFF1F5F9);
        rolePillFg = _ink500;
    }

    final Color avatarAccent =
        isActive ? AppColors.primary : AppColors.warningOrange;
    final Color borderColor = isActive
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.warningOrange.withValues(alpha: 0.30);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        splashColor: AppColors.primary.withValues(alpha: 0.06),
        highlightColor: AppColors.primary.withValues(alpha: 0.03),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 18.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gradient avatar badge with accent ring
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: avatarAccent.withValues(alpha: 0.20),
                    width: 1.2,
                  ),
                ),
                child: Container(
                  width: 44.w,
                  height: 44.w,
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
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.length >= 2
                          ? name.substring(0, 2).toUpperCase()
                          : name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: _ink900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isActive) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.warningOrange
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'INACTIVE',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warningOrange,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: _ink500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: rolePillBg,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: rolePillFg,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        if (deptName != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.business_rounded,
                                  size: 11.sp, color: AppColors.primary),
                              SizedBox(width: 3.w),
                              Text(
                                deptName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: _bgB,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    color: _ink500, size: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
