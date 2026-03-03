import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base/base_controller.dart';
import '../../../routes/app_routes.dart';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';
import '../../../data/repositories/organization_repository.dart';

class OrganizationSetupController extends BaseController {
  final OrganizationRepository _repository;

  OrganizationSetupController(this._repository);

  final TextEditingController orgNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController =
      TextEditingController(); // Can be removed if using only IntlPhoneField's internal state, but keep for safety/migration.

  final RxString fullPhoneNumber = ''.obs;
  final RxBool isPhoneValid = false.obs;

  final RxString orgCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    generateOrgCode();
  }

  void generateOrgCode() {
    final random = Random();
    final number = 1000 + random.nextInt(9000); // 4 digit number
    orgCode.value = 'ORG-$number-X';
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: orgCode.value));
    Get.rawSnackbar(
      messageText: const Center(
        child: Text(
          'Copied',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      margin: const EdgeInsets.symmetric(
        horizontal: 140,
        vertical: 40,
      ), // Centered and small
      borderRadius: 30,
      duration: const Duration(seconds: 1),
      padding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  void createOrganization() async {
    if (orgNameController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        fullPhoneNumber.value.isEmpty) {
      // Check fullPhoneNumber
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    // basic length check or rely on widget's visual feedback.
    // Ideally duplicate validation here or trust the user if the field didn't error visually.

    await performAsyncOperation(() async {
      try {
        await _repository.createOrganization(
          orgName: orgNameController.text,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          phoneNumber:
              fullPhoneNumber.value, // Send complete number with country code
        );
        Get.offNamed(AppRoutes.ORGANIZATION_SUCCESS); // Navigate to success
      } on DioException catch (e) {
        final message =
            e.response?.data['detail'] ??
            e.response?.data['message'] ??
            'An error occurred';
        Get.snackbar(
          'Error',
          message.toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Something went wrong',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    });
  }

  @override
  void onClose() {
    orgNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
