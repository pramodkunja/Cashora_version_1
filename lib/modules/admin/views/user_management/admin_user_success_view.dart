import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import '../../../../../routes/app_routes.dart';

class AdminUserSuccessView extends StatelessWidget {
  const AdminUserSuccessView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _red = AppColors.errorRed;
  static const _redBg = Color(0xFFFEF2F2);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final type = args['type'] ?? 'create';
    final userData = args['user'] as Map<String, dynamic>? ?? {};

    final String userName = userData['full_name'] ??
        userData['name'] ??
        '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
    final String userRole = userData['role'] ?? 'Requestor';
    final String email = userData['email'] ?? '';
    final String phone = userData['phone_number'] ?? userData['phone'] ?? '';
    final String createdDate = userData['created_at'] != null
        ? _formatDate(userData['created_at'])
        : _getCurrentDate();
    final String updatedDate = userData['updated_at'] != null
        ? _formatDate(userData['updated_at'])
        : _getCurrentDate();

    final bool isUpdate = type == 'update';
    final bool isDeactivate = type == 'deactivate';
    final bool isActivate = type == 'activate';

    final iconColor = isDeactivate ? _red : _green;
    final iconBg = isDeactivate ? _redBg : _greenBg;
    final iconData = isDeactivate
        ? Icons.person_off_rounded
        : (isUpdate || isActivate
            ? Icons.verified_user_rounded
            : Icons.check_rounded);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 24.h),

              // Icon
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.2),
                      blurRadius: 30.r,
                      spreadRadius: 4.r,
                    ),
                  ],
                ),
                child: Icon(iconData, color: iconColor, size: 54.sp),
              ),
              SizedBox(height: 28.h),

              Text(
                isDeactivate
                    ? AppText.userDeactivatedSuccess
                    : isActivate
                        ? AppText.userActivatedSuccess
                        : isUpdate
                            ? AppText.userUpdatedSuccessTitle
                            : AppText.userCreatedSuccessTitle,
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: _slate900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),

              Text(
                isDeactivate
                    ? '$userName\'s access has been revoked.'
                    : isActivate
                        ? 'The user has been activated and can now access the system.'
                        : isUpdate
                            ? AppText.userUpdatedSuccessDesc
                            : AppText.userCreatedSuccessDesc,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: _slate500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              // User Summary Card (skip for deactivate)
              if (!isDeactivate)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.w),
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _purple.withOpacity(0.15),
                                  _purple.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Center(
                              child: Text(
                                userName.length >= 2
                                    ? userName.substring(0, 2).toUpperCase()
                                    : 'U',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _purple,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _slate900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: _purpleLight,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    userRole.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                      color: _purple,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 28.h, color: const Color(0xFFF1F5F9)),
                      _infoRow(Icons.email_outlined, AppText.emailAddress, email),
                      SizedBox(height: 14.h),
                      _infoRow(Icons.phone_outlined, AppText.phone,
                          phone.isNotEmpty ? phone : 'Not provided'),
                      SizedBox(height: 14.h),
                      _infoRow(
                        Icons.calendar_today_outlined,
                        (isUpdate || isActivate)
                            ? AppText.updatedOn
                            : AppText.createdOn,
                        (isUpdate || isActivate) ? updatedDate : createdDate,
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 32.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () => Get.until(
                    (route) =>
                        route.settings.name == AppRoutes.ADMIN_USER_LIST,
                  ),
                  icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
                  label: Text(
                    AppText.goToManageUsers,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),

              if (type == 'create') ...[
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.person_add_rounded,
                        color: _purple, size: 18.sp),
                    label: Text(
                      AppText.addAnotherUser,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _purple,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _purple.withOpacity(0.3)),
                      backgroundColor: _purpleLight.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _purpleLight,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: _purple),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: _slate500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _slate900,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return _getCurrentDate();
    try {
      if (dateValue is String) {
        final dateTime = DateTime.parse(dateValue);
        return '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
      }
    } catch (_) {
      return _getCurrentDate();
    }
    return _getCurrentDate();
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${_getMonthName(now.month)} ${now.day}, ${now.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}
