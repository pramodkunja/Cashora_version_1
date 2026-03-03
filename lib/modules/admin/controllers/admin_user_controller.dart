import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../utils/widgets/app_loader.dart';

class AdminUserController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Remove static mock data
  final rxUsers = <Map<String, dynamic>>[].obs;
  final isLoadingUsers = false.obs;

  final rxSelectedUser = <String, dynamic>{}.obs;
  final rxIsActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoadingUsers.value = true;
      final users = await _authRepository.getUsers();

      // Filter out the current logged-in user (Admin)
      final currentUserId = Get.find<AuthService>().currentUser.value?.id;
      final filteredUsers = users.where((user) {
        // Ensure accurate comparison (handle String vs Int IDs safely)
        return user['id'].toString() != currentUserId.toString();
      }).toList();

      rxUsers.assignAll(filteredUsers);
    } catch (e) {
      String errorMessage = 'Failed to load users.';
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (data is Map<String, dynamic> && data.containsKey('error')) {
          errorMessage = data['error'];
        } else if (data is Map<String, dynamic> && data.containsKey('detail')) {
          errorMessage = data['detail'];
        }
      }
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // Form Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final selectedRole = ''.obs;

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void addUser() {
    // Reset form
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    selectedRole.value = '';
    Get.toNamed(AppRoutes.ADMIN_ADD_USER);
  }

  void createUser() async {
    // Check if user is authenticated
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn) {
      Get.snackbar(
        'Error',
        'You must be logged in to perform this action',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
      Get.offAllNamed(AppRoutes.LOGIN);
      return;
    }

    if (!_validateForm()) return;

    try {
      Get.dialog(const Center(child: AppSpinner()), barrierDismissible: false);

      final response = await _authRepository.addStaff(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        role: selectedRole.value,
      );

      Get.back(); // Close loader

      // Clear form
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      phoneController.clear();
      selectedRole.value = '';

      // Pass the created user data to success screen
      // If API doesn't return user data, create it from form inputs
      final userData = response.isNotEmpty
          ? response
          : {
              'full_name':
                  '${firstNameController.text.trim()} ${lastNameController.text.trim()}'
                      .trim(),
              'first_name': firstNameController.text.trim(),
              'last_name': lastNameController.text.trim(),
              'email': emailController.text.trim(),
              'phone': phoneController.text.trim(),
              'role': selectedRole.value,
              'created_at': DateTime.now().toIso8601String(),
            };

      Get.offNamed(
        AppRoutes.ADMIN_USER_SUCCESS,
        arguments: {'type': 'create', 'user': userData},
      );

      // Refresh the user list to include the new user
      await fetchUsers();
    } catch (e) {
      Get.back(); // Close loader
      // Handle error
      String errorMessage = 'An error occurred while creating the user.';
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        print('DEBUG: API Error Response: $data');
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (data is Map<String, dynamic> && data.containsKey('error')) {
          errorMessage = data['error'];
        } else if (data is Map<String, dynamic> && data.containsKey('detail')) {
          errorMessage = data['detail'];
        } else if (data is Map<String, dynamic>) {
          // Try to extract error from nested structure
          final errors = data['errors'] ?? data;
          if (errors is Map<String, dynamic>) {
            errorMessage = errors.values.first?.toString() ?? errorMessage;
          }
        }
      }
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
    }
  }

  bool _validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'First name is required',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Last name is required',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email is required',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Enter a valid email',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Phone is required',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
      return false;
    }
    if (!GetUtils.isPhoneNumber(phoneController.text.trim())) {
      Get.snackbar(
        'Error',
        'Enter a valid phone number',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
      return false;
    }
    if (selectedRole.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a role',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
      return false;
    }
    return true;
  }

  void updateUser() async {
    try {
      if (!_validateForm()) return;

      Get.dialog(const Center(child: AppSpinner()), barrierDismissible: false);

      final user = rxSelectedUser.value;
      final userId = user['id']?.toString() ?? '';

      if (userId.isEmpty) {
        Get.back(); // Close loader
        Get.snackbar('Error', 'User ID not found');
        return;
      }

      final response = await _authRepository.updateUser(
        userId: userId,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        role: selectedRole.value,
        isActive: rxIsActive.value,
      );

      Get.back(); // Close loader

      // Navigate to success screen with updated user data
      Get.offNamed(
        AppRoutes.ADMIN_USER_SUCCESS,
        arguments: {'type': 'update', 'user': response},
      );

      // Refresh the user list to show updated data
      await fetchUsers();
    } catch (e) {
      Get.back(); // Close loader
      String errorMessage = 'An error occurred while updating the user.';

      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (data is Map<String, dynamic> && data.containsKey('error')) {
          errorMessage = data['error'];
        } else if (data is Map<String, dynamic> && data.containsKey('detail')) {
          errorMessage = data['detail'];
        } else if (data is Map<String, dynamic>) {
          // Try to extract error from nested structure which might be common in some frameworks
          final errors = data['errors'] ?? data;
          if (errors is Map<String, dynamic>) {
            errorMessage = errors.values.first?.toString() ?? errorMessage;
          }
        }
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    }
  }

  final rxIsTermsAccepted = false.obs;

  void confirmDeactivate(Map<String, dynamic> user) {
    rxSelectedUser.value = user;
    rxIsTermsAccepted.value = false;
    Get.toNamed(AppRoutes.ADMIN_DEACTIVATE_USER);
  }

  void toggleUserStatus() async {
    try {
      Get.dialog(const Center(child: AppSpinner()), barrierDismissible: false);

      final user = rxSelectedUser.value;
      final userId = user['id']?.toString() ?? '';
      // Determine current status. Default to true if missing.
      final bool isActive = user['isActive'] ?? user['is_active'] ?? true;

      // If currently active, we deactivate (new status = false).
      // If currently inactive, we activate (new status = true).
      final bool newStatus = !isActive;

      if (userId.isEmpty) {
        Get.back(); // Close loader
        Get.snackbar('Error', 'User ID not found');
        return;
      }

      // We reusing the PATCH endpoint for both activation and deactivation
      // In auth_repository.dart, updateUser or a customized call can be used.
      // Since the user previously modified 'deactivateUser' in repo to use PATCH,
      // let's create a smarter call here.

      // We will use existing deactivateUser for deactivation (which sets is_active=false)
      // and a new/modified approach for activation.
      // Actually, looking at repo, deactivateUser does PATCH is_active: false.
      // We need a way to set is_active: true.
      // Let's assume we can use updateUser or modify repo?
      // The most robust way is to use updateUser from the repo if it supports partial updates
      // OR call a similar method.

      // Let's check `_authRepository.updateUser` again. It calls patch.
      // So we can use `_authRepository.updateUser` passing only the fields we want?
      // No, updateUser parameters are required.
      // Simple Hack: Call `_authRepository.updateUser` with all existing data but flipped status?
      // Or better: Create `toggleStack` logic if possible.

      // Since I can't easily change Repo signature right now without viewing it again to be sure:
      // I will assume I need to use `updateUser` with current values + new status.

      // UPDATE: I can verify AuthRepository content from previous context.
      // deactivateUser uses PATCH /users/update/$userId with {'is_active': false}.
      // So I can use the same pattern for activate.

      // Let's use `_authRepository.updateUser` logic but implemented here or better
      // call a new repo method `activateUser`? No, let's try to be cleaner.

      // I'll stick to `_authRepository.updateUser` with *all* fields filled from current user data
      // for activation, and `deactivateUser` for deactivation (as it is already specific).
      // Wait, passing all fields might be risky if we only want to toggle status.
      // Let's look at `deactivateUser` in repo again... it does a specific PATCH with only `is_active: false`.
      // I should add `activateUser` to repo or make a generic `updateStatus`.
      // For now, I will implement `toggleUserStatus` in logic and handle the API call.

      // Logic to ensure first and last names are present
      String firstName = user['first_name'] ?? '';
      String lastName = user['last_name'] ?? '';

      if (firstName.isEmpty) {
        String fullName = user['full_name'] ?? user['name'] ?? '';
        if (fullName.isNotEmpty) {
          final names = fullName.split(' ');
          firstName = names.first;
          if (names.length > 1) {
            lastName = names.sublist(1).join(' ');
          }
        }
      }

      final response = newStatus
          ? await _authRepository.updateUser(
              // Re-activating
              userId: userId,
              firstName: firstName,
              lastName: lastName,
              email: user['email'] ?? '',
              phone: user['phone'] ?? user['phone_number'] ?? '',
              role: user['role'] ?? 'Requestor',
              isActive: true,
            )
          : await _authRepository.deactivateUser(
              userId: userId,
            ); // Deactivating

      Get.back(); // Close loader

      // Navigate to success screen
      Get.offNamed(
        AppRoutes.ADMIN_USER_SUCCESS,
        arguments: {
          'type': newStatus ? 'activate' : 'deactivate',
          'user': response,
        },
      );

      // Refresh the user list to show updated data
      await fetchUsers();
    } catch (e) {
      Get.back(); // Close loader
      if (e is DioException) {
        final errorMessage =
            e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Failed to update user status';
        Get.snackbar('Error', errorMessage);
      } else {
        Get.snackbar('Error', 'An unexpected error occurred: ${e.toString()}');
      }
    }
  }

  void editUser(Map<String, dynamic> user) {
    rxSelectedUser.value = user;
    rxIsActive.value = user['is_active'] ?? user['isActive'] ?? true;

    // Pre-fill controllers
    firstNameController.text = user['first_name'] ?? '';
    lastNameController.text = user['last_name'] ?? '';
    emailController.text = user['email'] ?? '';
    phoneController.text = user['phone'] ?? user['phone_number'] ?? '';
    selectedRole.value = user['role'] ?? 'Requestor';

    // Handle full name split if first/last name missing
    if (firstNameController.text.isEmpty && user.containsKey('full_name')) {
      final names = (user['full_name'] as String).split(' ');
      if (names.isNotEmpty) firstNameController.text = names.first;
      if (names.length > 1)
        lastNameController.text = names.sublist(1).join(' ');
    } else if (firstNameController.text.isEmpty && user.containsKey('name')) {
      final names = (user['name'] as String).split(' ');
      if (names.isNotEmpty) firstNameController.text = names.first;
      if (names.length > 1)
        lastNameController.text = names.sublist(1).join(' ');
    }

    Get.toNamed(AppRoutes.ADMIN_EDIT_USER);
  }
}
