import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

/// Single tab descriptor used by [AppBottomBar].
class AppBottomBarItem {
  final IconData icon;
  final String label;
  const AppBottomBarItem({required this.icon, required this.label});
}

/// Shared floating "glass" bottom navigation bar — used by every role flow
/// (admin / accountant / requestor) so the design system is identical.
///
/// Design language:
///   - **Floating card** with deeply rounded corners (28r), inset from
///     the screen edges so it visibly hovers above the surface.
///   - **Glass aesthetic**: top-to-bottom gradient from pure white into a
///     very light accent wash, a crisp white hairline border for the
///     refracted-edge feel, and a soft accent-tinted drop shadow that
///     gives the bar a premium "lifted" depth.
///   - The whole widget sits inside a flat `ColoredBox` painted with the
///     app's slate-50 body background. This is what kills the blue /
///     black system colour that was bleeding through previously: the
///     padding region of the floating bar now matches the dashboards.
///   - Every tab gets an **equal-width** `Expanded` slot. There is no
///     active-tab expansion — horizontal overflow is mathematically
///     impossible regardless of label length or device width.
///   - **Active tab**: subtle white card with a slate hairline + tiny
///     drop shadow + accent icon + accent label + a short capsule
///     indicator below the label.
///   - **Inactive tab**: flat — grey icon (slate-400) + grey label
///     (slate-500). No card.
///   - Labels are always shown and wrapped in `FittedBox(scaleDown)`
///     so they never clip or overflow on narrow phones.
///   - The home indicator / Android gesture pill is respected via
///     `MediaQuery.padding.bottom`.
class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomBarItem> items;
  final Color accent;

  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.accent,
  });

  /// Slate-50. Matches every dashboard's body background so the bar's
  /// outer padding region disappears into the screen above it.
  static const _appBg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ColoredBox(
      // Solid backdrop: prevents the OS window colour (blue / black on
      // some Android builds and dark-mode contexts) from showing
      // through the padding around the floating bar.
      color: _appBg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          14.w,
          4.h,
          14.w,
          // Float above the iOS home indicator / Android gesture pill.
          bottomInset > 0 ? bottomInset + 2.h : 12.h,
        ),
        child: Container(
          decoration: BoxDecoration(
            // Glass gradient — pure white at the top, a hair of accent
            // wash at the bottom. Subtle enough to read as white at a
            // glance but adds the premium refraction feel up close.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color.alphaBlend(accent.withValues(alpha: 0.05), Colors.white),
              ],
            ),
            borderRadius: BorderRadius.circular(28.r),
            // Bright hairline = the "refracted edge" of the glass.
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              // Accent-tinted ambient shadow — gives the premium tint
              // beneath the floating bar.
              BoxShadow(
                color: accent.withValues(alpha: 0.14),
                blurRadius: 28.r,
                offset: Offset(0, 12.h),
              ),
              // Sharp key shadow for crispness.
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.h),
          child: Row(
            children: List.generate(items.length, (i) {
              return Expanded(
                child: _Tab(
                  item: items[i],
                  selected: i == currentIndex,
                  accent: accent,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final AppBottomBarItem item;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _Tab({
    required this.item,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  static const _slate400 = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          splashColor: accent.withValues(alpha: 0.10),
          highlightColor: accent.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: selected ? AppColors.slate100 : Colors.transparent,
                width: 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10.r,
                        offset: Offset(0, 3.h),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    item.icon,
                    key: ValueKey<bool>(selected),
                    color: selected ? accent : _slate400,
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? accent : AppColors.textSlate,
                        letterSpacing: 0.1,
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                // Bottom indicator capsule. Grows in width from 0 → 20w
                // when active. Height is fixed at 2.5.h so the row never
                // shifts as the user taps between tabs.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  height: 2.5.h,
                  width: selected ? 20.w : 0,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
