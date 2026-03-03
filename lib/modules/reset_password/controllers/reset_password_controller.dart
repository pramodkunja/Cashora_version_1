import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';

import '../../../core/base/base_controller.dart';

class ResetPasswordController extends BaseController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  void toggleNewPasswordVisibility() =>
      isNewPasswordHidden.value = !isNewPasswordHidden.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  final AuthRepository _authRepository = Get.find<AuthRepository>();
  late String email;
  late String otp;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    otp = args?['otp'] ?? '';
  }

  void resetPassword() async {
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    // TODO: Add password strength validation if required

    await performAsyncOperation(() async {
      try {
        await _authRepository.resetPassword(email, otp, newPass);
        Get.offNamed(AppRoutes.RESET_PASSWORD_SUCCESS);
      } on DioException catch (e) {
        final message =
            e.response?.data['detail'] ??
            e.response?.data['message'] ??
            'Failed to reset password';
        Get.snackbar('Error', message.toString());
      } catch (e) {
        Get.snackbar('Error', 'Something went wrong');
      }
    });
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
