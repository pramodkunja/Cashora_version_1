import 'package:flutter/material.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';

/// Variants for the user success screen. Determines header gradient,
/// hero icon, copy and whether the user summary card is shown.
enum AdminUserSuccessVariant { create, update, activate, deactivate }

AdminUserSuccessVariant adminUserSuccessVariantFor(String type) {
  switch (type) {
    case 'update':
      return AdminUserSuccessVariant.update;
    case 'activate':
      return AdminUserSuccessVariant.activate;
    case 'deactivate':
      return AdminUserSuccessVariant.deactivate;
    default:
      return AdminUserSuccessVariant.create;
  }
}

List<Color> adminUserSuccessGradientFor(AdminUserSuccessVariant v) {
  switch (v) {
    case AdminUserSuccessVariant.deactivate:
      return const [Color(0xFFE25C5C), Color(0xFFB91C1C)];
    case AdminUserSuccessVariant.create:
    case AdminUserSuccessVariant.update:
    case AdminUserSuccessVariant.activate:
      return const [Color(0xFF10B981), Color(0xFF047857)];
  }
}

Color adminUserSuccessAccentFor(AdminUserSuccessVariant v) =>
    v == AdminUserSuccessVariant.deactivate
        ? AppColors.errorRed
        : AppColors.successGreen;

String adminUserSuccessHeaderTitleFor(AdminUserSuccessVariant v) {
  switch (v) {
    case AdminUserSuccessVariant.create:
      return 'User created';
    case AdminUserSuccessVariant.update:
      return 'User updated';
    case AdminUserSuccessVariant.activate:
      return 'User activated';
    case AdminUserSuccessVariant.deactivate:
      return 'User deactivated';
  }
}

String adminUserSuccessTitleFor(AdminUserSuccessVariant v, String userName) {
  switch (v) {
    case AdminUserSuccessVariant.create:
      return AppText.userCreatedSuccessTitle;
    case AdminUserSuccessVariant.update:
      return AppText.userUpdatedSuccessTitle;
    case AdminUserSuccessVariant.activate:
      return AppText.userActivatedSuccess;
    case AdminUserSuccessVariant.deactivate:
      return AppText.userDeactivatedSuccess;
  }
}

String adminUserSuccessBodyFor(AdminUserSuccessVariant v, String userName) {
  final who = userName.isEmpty ? 'The user' : userName;
  switch (v) {
    case AdminUserSuccessVariant.create:
      return AppText.userCreatedSuccessDesc;
    case AdminUserSuccessVariant.update:
      return AppText.userUpdatedSuccessDesc;
    case AdminUserSuccessVariant.activate:
      return '$who has been activated and can now access the system.';
    case AdminUserSuccessVariant.deactivate:
      return '$who\'s access has been revoked. They can be reactivated anytime.';
  }
}
