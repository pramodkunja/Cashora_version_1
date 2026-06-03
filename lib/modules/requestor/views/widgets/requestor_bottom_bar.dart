import 'package:flutter/material.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/app_bottom_bar.dart';

class RequestorBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const RequestorBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      accent: AppColors.primary,
      items: [
        AppBottomBarItem(icon: Icons.home_rounded, label: AppText.navHome),
        AppBottomBarItem(
          icon: Icons.receipt_long_rounded,
          label: AppText.requests,
        ),
        AppBottomBarItem(icon: Icons.person_rounded, label: AppText.navProfile),
      ],
    );
  }
}
