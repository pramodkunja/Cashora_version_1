import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../data/repositories/request_repository.dart';
import '../../../../core/services/network_service.dart';

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
      final id = request['id'] ?? request['request_id'];
      if (id == null) {
        Get.snackbar(AppText.error, AppText.invalidRequestId);
        return;
      }

      final responseText = responseController.text.trim();
      await _requestRepository.submitClarification(id, responseText);

      // Optimistic update: flip status AND patch the latest clarification's
      // `response` + `responded_at` so the view's "outstanding question"
      // check (which inspects the last clarifications[] entry) flips to
      // false immediately — hiding the input until the admin asks again.
      final updatedRequest = Map<String, dynamic>.from(request);
      updatedRequest['status'] = 'clarification_responded';

      final rawList = updatedRequest['clarifications'];
      if (rawList is List && rawList.isNotEmpty) {
        final patched = rawList
            .map((e) => e is Map ? Map<String, dynamic>.from(e) : e)
            .toList();
        final lastIdx = patched.length - 1;
        final last = patched[lastIdx];
        if (last is Map<String, dynamic>) {
          last['response'] = responseText;
          last['responded_at'] = DateTime.now().toIso8601String();
          patched[lastIdx] = last;
        }
        updatedRequest['clarifications'] = patched;
      }

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
