import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/organization_repository.dart';
import '../../../../core/services/network_service.dart';

class AdminSetLimitsController extends GetxController {
  // Use Get.find to getting the instance if already registered or instantiate a new one
  // Typically repositories are registered in main.dart or a binding
  // If OrganizationRepository is not globally put, we might need to put it or find NetworkService
  late final OrganizationRepository _orgRepository;

  final deemedLimitController = TextEditingController();

  final isLoading = true.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize repository manually if not found, using NetworkService which is definitely found
    if (Get.isRegistered<OrganizationRepository>()) {
      _orgRepository = Get.find<OrganizationRepository>();
    } else {
      _orgRepository = OrganizationRepository(Get.find<NetworkService>());
    }

    fetchLimits();
  }

  Future<void> fetchLimits() async {
    try {
      isLoading.value = true;
      final response = await _orgRepository.getApprovalLimits();
      if (response != null) {
        // Backend might return 'deemed_limit' or 'deemed_approval_limit'. Handling both or checking repo.
        // Assuming consistent naming from previous turn, user changed POST key. GET key usually matches.
        // Safest to support 'deemed_approval_limit' based on user intent, but fallback to 'deemed_limit'.
        var val =
            response['deemed_approval_limit'] ?? response['deemed_limit'] ?? 0;
        deemedLimitController.text = val == 0 ? '' : val.toString();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch limits: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveLimits() async {
    if (!_validate()) return;

    try {
      isSaving.value = true;

      final deemed = int.parse(deemedLimitController.text.replaceAll(',', ''));

      await _orgRepository.updateApprovalLimits(deemedLimit: deemed);

      Get.back(); // Go back
      Get.snackbar(
        'Success',
        'Approval limit updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      String errorMessage = 'Failed to update limits';
      if (e.toString().contains('message')) {
        errorMessage = e.toString();
      }
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  bool _validate() {
    if (deemedLimitController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter deemed limit');
      return false;
    }
    if (!RegExp(
      r'^\d+$',
    ).hasMatch(deemedLimitController.text.replaceAll(',', ''))) {
      Get.snackbar('Error', 'Deemed limit must be a valid number');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    deemedLimitController.dispose();
    super.onClose();
  }
}
