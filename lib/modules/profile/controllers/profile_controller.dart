import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/user_update_request.dart';
import '../../../../data/repositories/user_repository.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository =
      Get.find<UserRepository>(); // Ensure this is put in binding
  final AuthService _authService = Get.find<AuthService>();

  final rxFirstName = ''.obs;
  final rxLastName = ''.obs;
  final rxName = ''.obs; // Keep full name for display if needed
  final rxEmail = ''.obs;
  final rxPhone = ''.obs;
  final rxRole = ''.obs;
  final rxOrgName = ''.obs;
  final rxOrgCode = ''.obs;
  final rxUserId = ''.obs;
  final rxDepartmentName = ''.obs;

  // Form Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final roleController = TextEditingController();

  final isSaving = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      // FETCH FROM API AS REQUESTED
      final user = await _userRepository.getMe();
      if (user != null) {
        _updateLocalState(user);
      } else {
        // Fallback to existing current user data if API returns null
        if (_authService.currentUser.value != null) {
          _updateLocalState(_authService.currentUser.value!);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Profile fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateLocalState(User user) {
    rxFirstName.value = user.firstName;
    rxLastName.value = user.lastName;

    // Construct display name logic
    String displayName = user.name;
    if ((displayName.isEmpty || displayName == 'Unknown') &&
        user.firstName.isNotEmpty) {
      displayName = '${user.firstName} ${user.lastName}'.trim();
    }

    rxName.value = displayName;
    rxEmail.value = user.email;
    rxRole.value = user.role;
    rxOrgName.value = user.orgName;
    rxOrgCode.value = user.orgCode;
    rxPhone.value = user.phoneNumber;
    rxUserId.value = user.id;
    rxDepartmentName.value = user.departmentName;
    _updateControllers();
  }

  void _updateControllers() {
    firstNameController.text = rxFirstName.value;
    lastNameController.text = rxLastName.value;
    emailController.text = rxEmail.value;
    phoneController.text = rxPhone.value;
    roleController.text = rxRole.value;
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    roleController.dispose();
    super.onClose();
  }

  void navigateToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  void logout() {
    _authService.logout(); // Ensure explicit logout
  }

  void editProfile() {
    _updateControllers();
    Get.toNamed(AppRoutes.EDIT_PROFILE);
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    try {
      final userId = rxUserId.value;
      if (userId.isEmpty) {
        Get.snackbar('Error', 'User ID not found');
        return;
      }

      // Email intentionally excluded — backend does not accept email changes
      // through PATCH /users/update/{id}. The UI's email field is read-only.
      final request = UserUpdateRequest(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );

      final updatedUser = await _userRepository.updateUser(userId, request);

      if (updatedUser != null) {
        _updateLocalState(updatedUser);
      }

      isSaving.value = false;
      Get.back();

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor, // Access theme directly
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      isSaving.value = false;
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  void navigateToManageUsers() {
    Get.toNamed(AppRoutes.ADMIN_USER_LIST);
  }

  void navigateToChangePassword() {
    Get.toNamed(AppRoutes.SETTINGS_CHANGE_PASSWORD);
  }
}

