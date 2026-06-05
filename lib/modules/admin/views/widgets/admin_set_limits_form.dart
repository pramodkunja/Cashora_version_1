import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/admin_set_limits_controller.dart';

/// Form section of the admin set-limits screen — info banner explaining what
/// the deemed limit means, followed by the large amount input card with the
/// ₹ prefix and INR pill suffix.
class AdminSetLimitsForm extends StatelessWidget {
  final AdminSetLimitsController controller;

  static const Color _bgB = Color(0xFFF8F7FF);
  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink300 = Color(0xFFCBD5E1);
  static const Color _ink200 = Color(0xFFE2E8F0);

  const AdminSetLimitsForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(),
        SizedBox(height: 22.h),
        _buildDeemedLimitCard(),
      ],
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
}
