import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/app_colors.dart';

/// White rounded section card with a purple-tinted leading icon disc and
/// a title. Used by every block on the completed-payment details screen.
class CompletedSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const CompletedSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

/// Single key–value row: label on the left (fixed width), value
/// right-aligned in slate-900 bold.
class CompletedInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const CompletedInfoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

/// Key–value row where the value is rendered as a purple pill — used
/// for categorical fields (e.g. category).
class CompletedInfoRowChip extends StatelessWidget {
  final String label;
  final String value;

  const CompletedInfoRowChip(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppColors.textSlate,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.purpleSurface,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// Long-form info block — purple bar + caps label on top, then a
/// boxed-out paragraph below. Used for purpose / description.
class CompletedInfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const CompletedInfoBlock(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty && value != '---';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: AppColors.textSlate,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.slate100, width: 1),
          ),
          child: Text(
            hasValue ? value : 'Not provided',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
              color: hasValue ? AppColors.textDark : AppColors.slate300,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Thin horizontal divider with vertical spacing — used between info
/// rows inside the request information card.
class CompletedRowDivider extends StatelessWidget {
  const CompletedRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(height: 1.h, color: AppColors.slate100),
    );
  }
}
