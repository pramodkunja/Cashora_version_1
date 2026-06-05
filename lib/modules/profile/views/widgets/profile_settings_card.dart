import 'package:flutter/material.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/profile_controller.dart';
import 'profile_action_row.dart';
import 'profile_card.dart';

class ProfileSettingsCard extends StatelessWidget {
  final ProfileController controller;

  const ProfileSettingsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(children: [
      ProfileActionRow(
        icon: Icons.lock_outline_rounded,
        title: AppText.changePassword,
        onTap: controller.navigateToChangePassword,
      ),
      ProfileActionRow(
        icon: Icons.settings_rounded,
        title: AppText.appSettings,
        onTap: controller.navigateToSettings,
      ),
    ]);
  }
}
