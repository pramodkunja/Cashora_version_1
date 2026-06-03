import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/app_bottom_bar.dart';

class AdminBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomBar({
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
          icon: Icons.assignment_turned_in_rounded,
          label: AppText.navApprovals,
        ),
        AppBottomBarItem(
          icon: Icons.history_rounded,
          label: AppText.navHistory,
        ),
        AppBottomBarItem(icon: Icons.person_rounded, label: AppText.navProfile),
      ],
    );
  }
}
