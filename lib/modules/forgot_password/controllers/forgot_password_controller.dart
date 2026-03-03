import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';

import '../../../core/base/base_controller.dart';

class ForgotPasswordController extends BaseController {
  final emailController = TextEditingController();

  final AuthRepository _authRepository = Get.find<AuthRepository>();

  Future<void> sendCode() async {
    if (emailController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your email');
      return;
    }

    await performAsyncOperation(() async {
      try {
        await _authRepository.forgotPassword(emailController.text.trim());
        Get.toNamed(
          AppRoutes.OTP_VERIFICATION,
          arguments: {'email': emailController.text.trim()},
        );
      } on DioException catch (e) {
        final message =
            e.response?.data['detail'] ??
            e.response?.data['message'] ??
            'An error occurred';
        Get.snackbar('Error', message.toString());
      } catch (e) {
        Get.snackbar('Error', 'Something went wrong');
      }
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
