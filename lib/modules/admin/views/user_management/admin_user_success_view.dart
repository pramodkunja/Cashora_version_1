import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import '../../../../../utils/date_helper.dart';
import '../../../../../routes/app_routes.dart';

/// Success screen shown after creating / updating / activating /
/// deactivating a user. Matches the gradient-header + card-form pattern
/// used elsewhere in the app — variant-coloured header (green for happy
/// path, red for deactivation), a hero icon overlapping the gradient
/// edge, the user summary, and a primary CTA.
class AdminUserSuccessView extends StatelessWidget {
  const AdminUserSuccessView({super.key});

  static const _slate600 = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final type = (args['type'] ?? 'create').toString();
    final userData = args['user'] as Map<String, dynamic>? ?? {};

    final userName = (userData['full_name'] ??
            userData['name'] ??
            '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}')
        .toString()
        .trim();
    final userRole = (userData['role'] ?? 'Requestor').toString();
    final email = (userData['email'] ?? '').toString();
    final phone =
        (userData['phone_number'] ?? userData['phone'] ?? '').toString();
    final createdAt = userData['created_at']?.toString();
    final updatedAt = userData['updated_at']?.toString();

    final variant = _variantFor(type);
    final isHappy = variant != _Variant.deactivate;
    final actionDate = (variant == _Variant.create
            ? createdAt
            : (updatedAt ?? createdAt)) ??
        '';

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, variant: variant),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero icon overlapping the gradient — fixed positive
                    // negative-margin via Transform.translate so it sits on
                    // the edge cleanly.
                    Transform.translate(
                      offset: Offset(0, -48.h),
                      child: Align(
                        alignment: Alignment.center,
                        child: _heroIcon(variant: variant),
                      ),
                    ),
                    // Pull the rest up to close the gap left by the icon.
                    Transform.translate(
                      offset: Offset(0, -36.h),
                      child: Column(
                        children: [
                          Text(
                            _titleFor(variant, userName),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            _bodyFor(variant, userName),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: _slate600,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // User summary card — hidden on deactivate, the
                          // header pill already says it all.
                          if (isHappy)
                            _userSummaryCard(
                              userName: userName,
                              userRole: userRole,
                              email: email,
                              phone: phone,
                              actionDate: actionDate,
                              variant: variant,
                            ),
                          SizedBox(height: 24.h),
                          _primaryCta(),
                          if (variant == _Variant.create) ...[
                            SizedBox(height: 12.h),
                            _secondaryCta(),
                          ],
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, {required _Variant variant}) {
    final colors = _gradientFor(variant);
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
              child: Icon(Icons.close_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _headerTitleFor(variant),
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

  // ── Hero icon ───────────────────────────────────────────────────────────
  Widget _heroIcon({required _Variant variant}) {
    final accent = _accentFor(variant);
    final icon = switch (variant) {
      _Variant.create => Icons.person_add_alt_1_rounded,
      _Variant.update => Icons.verified_user_rounded,
      _Variant.activate => Icons.check_circle_rounded,
      _Variant.deactivate => Icons.person_off_rounded,
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

  // ── User summary card ───────────────────────────────────────────────────
  Widget _userSummaryCard({
    required String userName,
    required String userRole,
    required String email,
    required String phone,
    required String actionDate,
    required _Variant variant,
  }) {
    final displayName = userName.isEmpty ? 'New user' : userName;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
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
                      AppColors.primary.withValues(alpha: 0.18),
                      AppColors.primary.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    _initialsOf(displayName),
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.purpleSurface,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        userRole.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(height: 1, color: AppColors.slate100),
          SizedBox(height: 16.h),
          _infoRow(Icons.email_outlined, AppText.emailAddress,
              email.isEmpty ? 'Not provided' : email),
          SizedBox(height: 14.h),
          _infoRow(Icons.phone_outlined, AppText.phone,
              phone.isEmpty ? 'Not provided' : phone),
          SizedBox(height: 14.h),
          _infoRow(
            Icons.event_outlined,
            variant == _Variant.create ? AppText.createdOn : AppText.updatedOn,
            DateHelper.formatDateTime(
              actionDate,
              fallback: DateHelper.getFormattedDate(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.purpleSurface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: AppColors.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSlate),
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ── CTAs ────────────────────────────────────────────────────────────────
  Widget _primaryCta() {
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

  Widget _secondaryCta() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: () => Get.back(),
        icon: Icon(Icons.person_add_rounded, color: AppColors.primary, size: 18.sp),
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

  // ── Variant mapping ─────────────────────────────────────────────────────
  _Variant _variantFor(String type) {
    switch (type) {
      case 'update':
        return _Variant.update;
      case 'activate':
        return _Variant.activate;
      case 'deactivate':
        return _Variant.deactivate;
      default:
        return _Variant.create;
    }
  }

  List<Color> _gradientFor(_Variant v) {
    switch (v) {
      case _Variant.deactivate:
        return const [Color(0xFFE25C5C), Color(0xFFB91C1C)];
      case _Variant.create:
      case _Variant.update:
      case _Variant.activate:
        return const [Color(0xFF10B981), Color(0xFF047857)];
    }
  }

  Color _accentFor(_Variant v) =>
      v == _Variant.deactivate ? AppColors.errorRed : AppColors.successGreen;

  String _headerTitleFor(_Variant v) {
    switch (v) {
      case _Variant.create:
        return 'User created';
      case _Variant.update:
        return 'User updated';
      case _Variant.activate:
        return 'User activated';
      case _Variant.deactivate:
        return 'User deactivated';
    }
  }

  String _titleFor(_Variant v, String userName) {
    switch (v) {
      case _Variant.create:
        return AppText.userCreatedSuccessTitle;
      case _Variant.update:
        return AppText.userUpdatedSuccessTitle;
      case _Variant.activate:
        return AppText.userActivatedSuccess;
      case _Variant.deactivate:
        return AppText.userDeactivatedSuccess;
    }
  }

  String _bodyFor(_Variant v, String userName) {
    final who = userName.isEmpty ? 'The user' : userName;
    switch (v) {
      case _Variant.create:
        return AppText.userCreatedSuccessDesc;
      case _Variant.update:
        return AppText.userUpdatedSuccessDesc;
      case _Variant.activate:
        return '$who has been activated and can now access the system.';
      case _Variant.deactivate:
        return '$who\'s access has been revoked. They can be reactivated anytime.';
    }
  }

  String _initialsOf(String name) {
    if (name.isEmpty) return 'U';
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}

enum _Variant { create, update, activate, deactivate }
