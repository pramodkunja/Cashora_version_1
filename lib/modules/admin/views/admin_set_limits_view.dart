import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../controllers/admin_set_limits_controller.dart';

class AdminSetLimitsView extends GetView<AdminSetLimitsController> {
  const AdminSetLimitsView({super.key});

  // ── Palette (matches departments + add-user + user-list) ──────────────
  static const Color _bgA = Color(0xFFF0E9FF);
  static const Color _bgB = Color(0xFFF8F7FF);
  static const Color _bgC = Color(0xFFEEF2FF);

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink300 = Color(0xFFCBD5E1);
  static const Color _ink200 = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _bgB,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _backgroundLayer(),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                _buildHeroBlock(),
                Expanded(child: _buildContentSheet(bottomInset)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── BACKGROUND ───────────────────

  Widget _backgroundLayer() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgA, _bgB, _bgC],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -90.h,
          right: -70.w,
          child: _bloom(280.w, AppColors.primary, 0.18),
        ),
        Positioned(
          top: 40.h,
          left: -60.w,
          child: _bloom(200.w, AppColors.primaryLight, 0.24),
        ),
      ],
    );
  }

  Widget _bloom(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  // ─────────────────── TOP BAR ───────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          _circleIconButton(Icons.arrow_back_rounded, () => Get.back()),
          Expanded(
            child: Center(
              child: Text(
                AppText.adminSetLimits,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink900,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(icon, color: _ink700, size: 20.sp),
        ),
      ),
    );
  }

  // ─────────────────── HERO BLOCK ───────────────────

  Widget _buildHeroBlock() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.20),
                width: 1.4,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14.r,
                  ),
                ],
              ),
              child: Icon(Icons.tune_rounded,
                  color: Colors.white, size: 22.sp),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approval limits',
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: _ink900,
                    letterSpacing: -0.4,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Set the auto-approval threshold for requests',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: _ink500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── CONTENT SHEET ───────────────────

  Widget _buildContentSheet(double bottomInset) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36.r),
          topRight: Radius.circular(36.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 24.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 24.h + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(),
            SizedBox(height: 22.h),
            _buildDeemedLimitCard(),
            SizedBox(height: 28.h),
            _buildSaveButton(),
            SizedBox(height: 12.h),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  // ─────────────────── INFO BANNER ───────────────────

  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.primary, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              AppText.limitConfigDesc,
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

  // ─────────────────── DEEMED LIMIT CARD ───────────────────

  Widget _buildDeemedLimitCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (icon + title)
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.tune_rounded,
                    color: AppColors.primary, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                AppText.deemedLimitLabel,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink900,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          // Big amount input
          Container(
            decoration: BoxDecoration(
              color: _bgB,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: _ink200),
            ),
            child: TextField(
              controller: controller.deemedLimitController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: AppColors.primary,
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: _ink900,
                letterSpacing: -0.4,
              ),
              decoration: InputDecoration(
                prefixIcon: Container(
                  width: 48.w,
                  alignment: Alignment.center,
                  child: Text(
                    '₹',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                suffixIcon: Container(
                  width: 56.w,
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      AppText.inrSuffix,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                hintText: '0',
                hintStyle: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink300,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 18.h, horizontal: 16.w),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            AppText.deemedLimitDesc,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: _ink500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── BUTTONS ───────────────────

  Widget _buildSaveButton() {
    return Obx(() {
      final busy = controller.isSaving.value;
      return Container(
        height: 54.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: busy
                ? [
                    AppColors.primary.withValues(alpha: 0.55),
                    AppColors.primaryLight.withValues(alpha: 0.55),
                  ]
                : [AppColors.primary, AppColors.primaryLight],
          ),
          boxShadow: busy
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.40),
                    blurRadius: 18.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: busy ? null : controller.saveLimits,
            borderRadius: BorderRadius.circular(16.r),
            child: Center(
              child: busy
                  ? SizedBox(
                      height: 22.h,
                      width: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded,
                            color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          AppText.saveLimits,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _ink200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          backgroundColor: _bgB,
        ),
        child: Text(
          AppText.cancel,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: _ink700,
          ),
        ),
      ),
    );
  }
}
