import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../data/repositories/request_repository.dart';
import '../../../../core/services/network_service.dart';
import '../../../../routes/app_routes.dart';

import '../../../../utils/app_text.dart';

class ProvideClarificationController extends GetxController {
  late final RequestRepository _requestRepository;
  final request = {}.obs;
  final responseController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _requestRepository = RequestRepository(Get.find<NetworkService>());
    if (Get.arguments != null) {
      request.value = Get.arguments;
    }
  }

  @override
  void onClose() {
    responseController.dispose();
    super.onClose();
  }

  Future<void> submitClarification() async {
    if (responseController.text.trim().isEmpty) {
      Get.snackbar(AppText.error, AppText.enterExplanation);
      return;
    }

    try {
      isLoading.value = true;
      final id =
          request['id'] ?? request['request_id']; // Ensure we use numeric ID
      if (id == null) {
        Get.snackbar(AppText.error, AppText.invalidRequestId);
        return;
      }

      final int requestId = id is int ? id : int.parse(id.toString());

      // Call repository method
      await _requestRepository.submitClarification(
        requestId,
        responseController.text.trim(),
      );

      // Update local state in-place
      // We cannot fetch full details as endpoint is missing
      // await _fetchFullDetails();

      // Optimistic update status if fetch failed or just to be sure
      final updatedRequest = Map<String, dynamic>.from(request);
      updatedRequest['status'] =
          'clarification_responded'; // Update status to reflect change
      request.value = updatedRequest;

      responseController.clear();
      Get.snackbar(AppText.success, AppText.clarificationSubmitted);

      // Ideally navigate back or refresh previous list
      // Get.back(result: true); // Optionally return result to refresh list
    } catch (e) {
      Get.snackbar(AppText.error, AppText.failedToSubmit(e.toString()));
    } finally {
      isLoading.value = false;
    }
  }
}
