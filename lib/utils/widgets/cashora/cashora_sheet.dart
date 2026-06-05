import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_colors.dart';
import 'cashora_colors.dart';

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
          ? SingleChildScrollView(padding: scaledPadding, child: content)
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
