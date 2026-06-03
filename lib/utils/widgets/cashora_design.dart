// Cashora shared design system.
//
// Compose any screen with these primitives. They encode the visual
// language we landed on for the auth flow + add-user + departments:
//
//   • Light lavender gradient background with soft purple blooms
//   • Top bar with circular back button + centered title
//   • Gradient hero icon badge with subtle accent ring
//   • Uppercase eyebrow pill ("NEW USER", "WELCOME", etc.)
//   • Bold headline + slate subtitle pair
//   • Section header (icon-in-tinted-square + title)
//   • White sheet with curved top corners + primary-tinted shadow
//   • M3 floating-label inputs (via cashoraInputDecoration)
//   • Gradient pill button with purple glow
//   • One-shot slide-up + fade-in entrance animation
//
// Most widgets are stateless and configurable. Import once per screen:
//     import '<rel>/utils/widgets/cashora_design.dart';
//
// New screens should prefer composing from here over inlining patterns.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_colors.dart';

// ─────────────────────────── PALETTE ───────────────────────────

class CashoraColors {
  CashoraColors._();

  // Background gradient stops (top → bottom).
  static const Color bgA = Color(0xFFF0E9FF);
  static const Color bgB = Color(0xFFF8F7FF);
  static const Color bgC = Color(0xFFEEF2FF);

  // Ink scale.
  static const Color ink900 = Color(0xFF0F172A);
  static const Color ink700 = Color(0xFF334155);
  static const Color ink500 = Color(0xFF64748B);
  static const Color ink300 = Color(0xFFCBD5E1);
  static const Color ink200 = Color(0xFFE2E8F0);

  // Neutral surface (used as input fill, secondary buttons, chips).
  static const Color surface = Color(0xFFF8FAFC);
}

// ─────────────────────────── BACKGROUND ───────────────────────────

/// Full-screen lavender gradient with 2–3 soft radial blooms in the
/// corners. Drop this as the first child of a `Stack` to set the scene.
class AppBackground extends StatelessWidget {
  /// Adds a third bloom on the right-mid for a richer composition
  /// (useful on taller screens / list pages).
  final bool extraBloom;

  const AppBackground({super.key, this.extraBloom = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CashoraColors.bgA,
                CashoraColors.bgB,
                CashoraColors.bgC,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -90.h,
          right: -70.w,
          child: Bloom(size: 280.w, color: AppColors.primary, opacity: 0.20),
        ),
        Positioned(
          top: 40.h,
          left: -60.w,
          child: Bloom(
              size: 200.w, color: AppColors.primaryLight, opacity: 0.26),
        ),
        if (extraBloom)
          Positioned(
            top: 160.h,
            right: -30.w,
            child: Bloom(
                size: 140.w,
                color: AppColors.primaryLight,
                opacity: 0.22),
          ),
      ],
    );
  }
}

/// Soft radial bloom — the decorative blurred circle.
class Bloom extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const Bloom({
    super.key,
    required this.size,
    required this.color,
    this.opacity = 0.20,
  });

  @override
  Widget build(BuildContext context) {
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
}

// ─────────────────────────── TOP BAR ───────────────────────────

/// Circular white button with an icon — typically a back button.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(
            icon,
            color: iconColor ?? CashoraColors.ink700,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

/// Standard top bar: back button on the left, centered title, optional
/// trailing widget. If [onBack] is null, the leading slot is reserved
/// (so the title stays centered).
class AppTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final back = onBack != null
        ? CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack!,
          )
        : SizedBox(width: 40.w);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          back,
          Expanded(
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: CashoraColors.ink900,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          trailing ?? SizedBox(width: 40.w),
        ],
      ),
    );
  }
}

// ─────────────────────────── HERO BADGE ───────────────────────────

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
    final colors = gradient ??
        [AppColors.primary, AppColors.primaryLight];
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

// ─────────────────────────── EYEBROW PILL ───────────────────────────

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

// ─────────────────────────── SECTION HEADER ───────────────────────────

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

// ─────────────────────────── WHITE SHEET ───────────────────────────

/// Curved-top white container with a soft primary-tinted upward shadow.
/// Use as the form / list container at the bottom of a screen.
///
/// Pass [bottomInset] (typically `MediaQuery.of(context).padding.bottom`)
/// to ensure the last child clears the home indicator. Set [showHandle]
/// to draw a small grey "modal grip" at the top.
class WhiteSheet extends StatelessWidget {
  final Widget child;
  final double topRadius;
  final bool showHandle;
  // EdgeInsets (not EdgeInsetsGeometry) so we can read its sides to
  // re-scale via ScreenUtil and add the system bottom inset.
  final EdgeInsets padding;
  final double bottomInset;
  final bool scrollable;

  const WhiteSheet({
    super.key,
    required this.child,
    this.topRadius = 42,
    this.showHandle = true,
    this.padding = const EdgeInsets.fromLTRB(26, 14, 26, 26),
    this.bottomInset = 0,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaledPadding = EdgeInsets.fromLTRB(
      padding.left.w,
      padding.top.h,
      padding.right.w,
      padding.bottom.h + bottomInset,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHandle) ...[
          Center(child: const SheetHandle()),
          SizedBox(height: 22.h),
        ],
        child,
      ],
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topRadius.r),
          topRight: Radius.circular(topRadius.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 28.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      child: scrollable
          ? SingleChildScrollView(
              padding: scaledPadding,
              child: content,
            )
          : Padding(padding: scaledPadding, child: content),
    );
  }
}

/// Small slate grip pill — the modal-sheet handle.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: CashoraColors.ink200,
        borderRadius: BorderRadius.circular(2.h),
      ),
    );
  }
}

// ─────────────────────────── GRADIENT BUTTON ───────────────────────────

/// Full-width gradient pill with primary-purple glow shadow.
///
/// Pass an [Rx<bool>] for [loading] if you want it driven by Obx — or
/// pass a plain bool. Use [leadingIcon] / [trailingIcon] for adornments.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;
  final double radius;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 54,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final bool busy = loading;
    return Container(
      width: double.infinity,
      height: height.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
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
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(radius.r),
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
                      if (leadingIcon != null) ...[
                        Icon(leadingIcon, color: Colors.white, size: 20.sp),
                        SizedBox(width: 10.w),
                      ],
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        SizedBox(width: 8.w),
                        Icon(trailingIcon, color: Colors.white, size: 18.sp),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── ENTRANCE WRAP ───────────────────────────

/// One-shot slide-up + fade-in animation that runs the first (and only)
/// time the widget mounts. Stateless — no controller needed.
///
/// Stagger sibling children by passing **longer** durations to later
/// items (a 1100ms wrap visibly settles after a 700ms one).
class EntranceWrap extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const EntranceWrap({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.offset = 20,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, t, c) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

// ─────────────────────────── INPUT DECORATION ───────────────────────────

/// Standard M3 floating-label `InputDecoration`. Labels start inside the
/// field, glide into the border on focus or fill, and turn primary purple.
///
/// Use with `TextField`, `TextFormField`, `DropdownButtonFormField`, etc.
InputDecoration cashoraInputDecoration({
  required String label,
  required IconData icon,
  Widget? suffix,
  bool dense = false,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: CashoraColors.ink500,
    ),
    floatingLabelStyle: GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
    prefixIcon: Padding(
      padding: EdgeInsets.only(left: 12.w, right: 6.w),
      child: Icon(icon, color: CashoraColors.ink500, size: 18.sp),
    ),
    prefixIconConstraints:
        BoxConstraints(minWidth: 36.w, minHeight: 36.h),
    suffixIcon: suffix,
    filled: true,
    fillColor: CashoraColors.surface,
    isDense: dense,
    contentPadding:
        EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
    hintStyle:
        GoogleFonts.inter(fontSize: 13.sp, color: CashoraColors.ink300),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: CashoraColors.ink200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: CashoraColors.ink200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: AppColors.primary, width: 1.8),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: CashoraColors.ink200),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
    ),
  );
}

// ─────────────────────────── HEADLINE BLOCK ───────────────────────────

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

// ─────────────────────────── CASHORA SCAFFOLD ───────────────────────────

/// Convenience scaffold that wires up the background, optional top bar,
/// hero content, and a white sheet at the bottom. Use for any screen
/// that follows the auth/form pattern; for screens with custom layouts,
/// compose the primitives above directly.
class CashoraScaffold extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final Widget? topBarTrailing;
  final Widget hero;
  final Widget sheet;
  final bool extraBloom;
  final Widget? floatingActionButton;

  const CashoraScaffold({
    super.key,
    this.title,
    this.onBack,
    this.topBarTrailing,
    required this.hero,
    required this.sheet,
    this.extraBloom = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashoraColors.bgB,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          AppBackground(extraBloom: extraBloom),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                if (title != null)
                  AppTopBar(
                    title: title!,
                    onBack: onBack ?? () => Get.back(),
                    trailing: topBarTrailing,
                  ),
                hero,
                Expanded(child: sheet),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
