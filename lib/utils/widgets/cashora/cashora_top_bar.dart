import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cashora_colors.dart';

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
