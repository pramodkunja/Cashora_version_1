import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_colors.dart';
import '../../app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;
  final EdgeInsetsGeometry? padding;

  final Color? backgroundColor;
  final Color? textColor;

  final BorderSide? border;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // If null, fits content
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor:
              backgroundColor ?? AppColors.infoBg, // Default light blue
          foregroundColor: textColor ?? AppColors.textDark,
          padding:
              padding ?? EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
            side: border ?? BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Hug content
          children: [
            if (icon != null) ...[icon!, SizedBox(width: 8.w)],
            Flexible(
              child: Text(
                text,
                style: AppTextStyles.buttonText.copyWith(
                  color: textColor ?? AppColors.textDark,
                  fontSize: 16.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
