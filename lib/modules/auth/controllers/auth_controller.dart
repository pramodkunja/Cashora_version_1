import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/user_roles.dart'; // Added Import
import '../../../routes/app_routes.dart';

class AuthController extends BaseController {
  final AuthService _authService = Get.find<AuthService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password');
      return;
    }

    if (!_isValidEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    if (!_isValidPassword(password)) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }

    // Unfocus keyboard to prevent 'TextEditingController used after disposed' error
    FocusManager.instance.primaryFocus?.unfocus();

    await performAsyncOperation(() async {
      await _authService.login(email, password);

      final user = _authService.currentUser.value;
      if (user != null) {
        final role = user.role.toLowerCase().trim();
        if (role == UserRoles.ADMIN || role == UserRoles.SUPER_ADMIN) {
          Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
        } else if (role == UserRoles.ACCOUNTANT) {
          Get.offAllNamed(AppRoutes.ACCOUNTANT_DASHBOARD);
        } else if (role == UserRoles.REQUESTOR) {
          Get.offAllNamed(AppRoutes.REQUESTOR);
        } else {
          // SECURITY FIX: Deny unknown roles
          Get.snackbar('Access Denied', 'Unknown user role: ${user.role}');
          await _authService.logout(); // Force logout
        }
      } else {
        // SECURITY FIX: Do not assume Requestor if user is null
        Get.snackbar('Error', 'Login failed: Unable to retrieve user details.');
      }
    });
  }

  @override
  void onClose() {
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}
