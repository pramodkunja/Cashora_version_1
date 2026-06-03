import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The standard purple-gradient app bar used across 24+ screens
/// (dashboards, request details, history, profile, set limits,
/// notifications, change password, …).
///
/// Migrates 24 inline `_buildHeader(BuildContext)` definitions to a single
/// reusable widget. Each variant differs only in: title, whether to show
/// the back button, trailing widget(s), and optional subtitle / extra
/// children below the title row.
///
/// Default behaviour:
///   • Top padding includes `MediaQuery.padding.top + 14.h` (status bar safe)
///   • Bottom rounded by 32.r
///   • Standard 7C68D4 → 5B45B0 gradient
///   • Back button uses `Get.back()` unless [onBack] is provided
///   • If [onBack] is `null`, the leading slot collapses (no back button)
class AppGradientHeader extends StatelessWidget {
  /// Centered or left-aligned (when [leftAlignTitle] is true) heading text.
  final String title;

  /// Tap target for the leading back button. Pass `null` to hide the back
  /// button entirely (e.g. when the header is a root tab). Default is
  /// `() => Get.back()` when not provided.
  final VoidCallback? onBack;

  /// Whether to show the back button at all. Independent of [onBack] —
  /// pass `false` on root tabs even if a callback exists.
  final bool showBack;

  /// Optional trailing widget (chip, action button, status pill, etc.).
  final Widget? trailing;

  /// Optional small subtitle directly below the title row.
  final String? subtitle;

  /// Optional extra children stacked below the title row (and subtitle if any).
  /// Useful for embedded avatars, search bars, or tab strips.
  final List<Widget>? children;

  /// Override the default bottom-corner radius. Leave null for 32.r.
  final double? bottomRadius;

  /// Whether the title should be left-aligned (next to back button) or
  /// centered with the leading/trailing slots fixed-width. Default is
  /// left-aligned (matches the existing 24 occurrences).
  final bool leftAlignTitle;

  const AppGradientHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
    this.trailing,
    this.subtitle,
    this.children,
    this.bottomRadius,
    this.leftAlignTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final back = showBack
        ? _buildBackButton(onBack ?? () => Get.back())
        : SizedBox(width: 0.w);

    final Widget titleWidget = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        22.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius ?? 32.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBack) ...[
                back,
                SizedBox(width: 12.w),
              ],
              if (leftAlignTitle) ...[
                Expanded(child: titleWidget),
              ] else ...[
                const Spacer(),
                titleWidget,
                const Spacer(),
              ],
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.only(left: showBack ? 48.w : 0),
              child: Text(
                subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
          if (children != null && children!.isNotEmpty) ...children!,
        ],
      ),
    );
  }

  Widget _buildBackButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
    );
  }
}
