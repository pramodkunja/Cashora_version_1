import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';
import 'cashora_colors.dart';

/// Gradient circle with an icon inside, wrapped in a subtle accent ring.
/// Used as the visual centerpiece on auth / form screens.
class HeroBadge extends StatelessWidget {
  final IconData icon;
  final double diameter;
  final double iconSize;
  final List<Color>? gradient;
  final bool ringed;

  const HeroBadge({
    super.key,
    required this.icon,
    this.diameter = 96,
    this.iconSize = 44,
    this.gradient,
    this.ringed = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? [AppColors.primary, AppColors.primaryLight];
    final inner = Container(
      width: diameter.w,
      height: diameter.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.35),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: iconSize.sp),
    );

    if (!ringed) return inner;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.first.withValues(alpha: 0.22),
          width: 1.4,
        ),
      ),
      child: inner,
    );
  }
}

/// Small uppercase tag (`"NEW USER"`, `"WELCOME"`, etc.) in a
/// primary-tinted pill. Use it above the headline.
class EyebrowPill extends StatelessWidget {
  final String text;
  final Color? color;

  const EyebrowPill({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: c,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

/// Icon-in-tinted-square + section title — the divider between form
/// groupings ("Personal Information", "Organization & Role", etc.).
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: CashoraColors.ink900,
          ),
        ),
      ],
    );
  }
}

/// Eyebrow pill → bold headline → slate subtitle, centered. The standard
/// hero text block for auth / form screens (and the top of confirmation
/// dialogs). Pass any segment as null to omit it.
class HeroHeadline extends StatelessWidget {
  final String? eyebrow;
  final String headline;
  final String? subtitle;
  final TextAlign textAlign;
  final double headlineSize;

  const HeroHeadline({
    super.key,
    this.eyebrow,
    required this.headline,
    this.subtitle,
    this.textAlign = TextAlign.center,
    this.headlineSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          EyebrowPill(text: eyebrow!),
          SizedBox(height: 12.h),
        ],
        Text(
          headline,
          textAlign: textAlign,
          style: GoogleFonts.outfit(
            fontSize: headlineSize.sp,
            fontWeight: FontWeight.w700,
            color: CashoraColors.ink900,
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8.h),
          Text(
            subtitle!,
            textAlign: textAlign,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: CashoraColors.ink500,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
