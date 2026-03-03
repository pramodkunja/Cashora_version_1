import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

class CustomListTile extends StatelessWidget {
  final IconData? icon; // Optional leading icon (used in Settings)
  final Widget? leadingIconWidget; // Custom leading widget (e.g. colored box)
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  const CustomListTile({
    Key? key,
    required this.title,
    this.icon,
    this.leadingIconWidget,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 4,
          ),
          leading:
              leadingIconWidget ??
              (icon != null
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).scaffoldBackgroundColor, // Placeholder color
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: AppColors.primaryBlue, size: 20),
                    )
                  : null), // Handle no icon case (e.g. Profile details)
          title: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTextStyles.bodyMedium.color,
              fontSize: 13,
            ),
          ), // Label style
          subtitle: subtitle != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    subtitle!,
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                  ),
                )
              : null,
          trailing:
              trailing ??
              (onTap != null
                  ? Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppTextStyles.bodySmall.color,
                    )
                  : null),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).dividerColor,
          ),
      ],
    );
  }
}
