import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../core/services/auth_service.dart';

class AccountantProfileController extends GetxController {
  final UserRepository _userRepository =
      Get.find<UserRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final rxName = ''.obs;
  final rxEmail = ''.obs;
  final rxPhone = ''.obs;
  final rxRole = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final user = await _userRepository.getMe();
      if (user != null) {
        rxName.value = user.name;
        rxEmail.value = user.email;
        rxRole.value = user.role;
        rxPhone.value = user.phoneNumber;
      }
    } catch (e) {
      print('Error fetching accountant profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void editProfile() async {
    await Get.toNamed(AppRoutes.EDIT_PROFILE);
    fetchProfile();
  }

  void navigateToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  void logout() {
    _authService.logout();
  }

  void navigateToChangePassword() {
    Get.toNamed(AppRoutes.SETTINGS_CHANGE_PASSWORD);
  }

  void onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.ACCOUNTANT_DASHBOARD);
        break;
      case 1:
        Get.offNamed(AppRoutes.ACCOUNTANT_PAYMENTS);
        break;
      case 2:
        break;
      case 3:
        break;
    }
  }
}
