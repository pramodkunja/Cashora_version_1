import 'package:get/get.dart';

import '../../modules/profile/controllers/profile_controller.dart';
import '../../modules/profile/controllers/settings_controller.dart';
import '../../modules/profile/views/edit_profile_view.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/profile/views/settings_view.dart';
import '../../modules/settings/views/appearance_view.dart';
import '../../modules/settings/views/change_password_view.dart';
import '../../modules/settings/views/notifications_view.dart';
import '../app_routes.dart';

/// Profile + settings routes shared across every role (admin, accountant,
/// requestor). Each role's main shell uses these via the global router.
final List<GetPage> sharedRoutes = [
  GetPage(
    name: AppRoutes.PROFILE,
    page: () => const ProfileView(),
    binding: BindingsBuilder(() {
      Get.put(ProfileController());
    }),
  ),
  GetPage(
    name: AppRoutes.EDIT_PROFILE,
    page: () => const EditProfileView(),
    binding: BindingsBuilder(() {
      Get.put(ProfileController());
    }),
  ),
  GetPage(
    name: AppRoutes.SETTINGS,
    page: () => const SettingsView(),
    binding: BindingsBuilder(() {
      Get.put(SettingsController());
    }),
  ),
  GetPage(
    name: AppRoutes.SETTINGS_NOTIFICATIONS,
    page: () => const NotificationsView(),
    binding: BindingsBuilder(() {
      Get.put(SettingsController());
    }),
  ),
  GetPage(
    name: AppRoutes.SETTINGS_APPEARANCE,
    page: () => const AppearanceView(),
    binding: BindingsBuilder(() {
      Get.put(SettingsController());
    }),
  ),
  GetPage(
    name: AppRoutes.SETTINGS_CHANGE_PASSWORD,
    page: () => const ChangePasswordView(),
    binding: BindingsBuilder(() {
      Get.put(SettingsController());
    }),
  ),
];
