import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';

/// Small caps section label (`REQUESTOR`, `DETAILS`, `ATTACHMENTS`,
/// `TIMELINE`) used above each card on the request details screen.
class RequestSectionLabel extends StatelessWidget {
  final String text;
  const RequestSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSlate,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// White rounded card with a soft drop shadow — the standard container
/// wrapping every section on the request details screen.
class RequestWhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const RequestWhiteCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Key-value row used inside the details card. Label fixed-width on
/// the left, value right-aligned in dark slate. `multiline` removes
/// the max-lines cap for long descriptions.
class RequestKvRow extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;

  const RequestKvRow(
    this.label,
    this.value, {
    super.key,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textSlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              maxLines: multiline ? null : 2,
              overflow: multiline ? null : TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slim slate-100 horizontal divider.
class RequestRowDivider extends StatelessWidget {
  const RequestRowDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: const Color(0xFFF1F5F9));
}
