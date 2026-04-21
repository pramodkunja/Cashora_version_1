import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_text.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../../../core/services/network_service.dart';

enum ClarificationState { pending, responded, askingAgain }

class AdminClarificationStatusController extends GetxController {
  final Rx<ClarificationState> state = ClarificationState.pending.obs;
  final RxMap<String, dynamic> request = <String, dynamic>{}.obs;
  AdminRepository? _adminRepository;

  AdminRepository get repo =>
      _adminRepository ??= AdminRepository(Get.find<NetworkService>());

  final reasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _adminRepository = AdminRepository(Get.find<NetworkService>());

    final args = Get.arguments ?? {};
    request.value = _deepCopy(args);
    _updateStateFromRequest(request);

    refreshRequest();
  }

  Future<void> refreshRequest() async {
    try {
      final id = request['id'];
      if (id == null) return;

      final results = await repo.getOrgExpenses(status: 'clarification');

      final freshItem = results.firstWhere(
        (item) => item['id'].toString() == id.toString(),
        orElse: () => <String, dynamic>{},
      );

      if (freshItem.isNotEmpty) {
        // Preserve clarifications from original data if fresh data doesn't have them
        final originalClarifications = request['clarifications'];
        final freshClarifications = freshItem['clarifications'];

        if ((freshClarifications == null || (freshClarifications is List && freshClarifications.isEmpty)) &&
            originalClarifications != null &&
            originalClarifications is List &&
            originalClarifications.isNotEmpty) {
          freshItem['clarifications'] = originalClarifications;
        }

        request.value = _deepCopy(freshItem);
        _updateStateFromRequest(request);
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Error refreshing request: $e");
      // Don't overwrite — keep original data from arguments
    }
  }

  void _updateStateFromRequest(Map<String, dynamic> item) {
    state.value = _determineState(item);
  }

  ClarificationState _determineState(Map<String, dynamic> item) {
    // 1. Check status string first — most reliable
    final status = item['status']?.toString() ?? '';
    if (status == 'clarification_responded') {
      return ClarificationState.responded;
    }

    // 2. Check clarifications array for actual response content
    final raw = item['clarifications'];
    if (raw != null && raw is List && raw.isNotEmpty) {
      final lastItem = raw.last;
      if (lastItem is Map) {
        final response = lastItem['response']?.toString() ?? '';
        if (response.isNotEmpty) {
          return ClarificationState.responded;
        }
      }
    }

    return ClarificationState.pending;
  }

  /// Deep copy a map so nested Lists/Maps are new instances,
  /// preventing RxMap from losing references.
  Map<String, dynamic> _deepCopy(dynamic source) {
    if (source is Map) {
      return source.map<String, dynamic>((key, value) {
        if (value is Map) return MapEntry(key.toString(), _deepCopy(value));
        if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((e) => e is Map ? _deepCopy(e) : e).toList(),
          );
        }
        return MapEntry(key.toString(), value);
      });
    }
    return {};
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  void startAskAgain() {
    state.value = ClarificationState.askingAgain;
  }

  Future<void> submitAskAgain() async {
    final String question = reasonController.text.trim();
    if (question.isEmpty) {
      Get.snackbar("Error", "Please provide a reason/question");
      return;
    }
    try {
      final id = request['id'];
      if (id == null) return;

      final numericId = id is int ? id : int.parse(id.toString());
      await repo.askClarification(numericId, question);

      Get.snackbar(AppText.success, AppText.sentBackSuccessfully);

      // Update local state
      final updatedClarifications = List<Map<String, dynamic>>.from(
        request['clarifications'] ?? [],
      );
      updatedClarifications.add({
        'question': question,
        'response': '',
        'asked_at': DateTime.now().toIso8601String(),
        'responded_at': '',
      });

      final updatedRequest = Map<String, dynamic>.from(request);
      updatedRequest['clarifications'] = updatedClarifications;
      updatedRequest['status'] = 'clarification_required';
      request.value = updatedRequest;

      state.value = ClarificationState.pending;
      reasonController.clear();
    } catch (e) {
      Get.snackbar("Error", "Failed to ask clarification: $e");
    }
  }

  Future<void> approve() async {
    try {
      final id = request['id'];
      if (id == null) return;

      await repo.approveRequest(id);

      Get.back(result: true);
      Get.snackbar(AppText.approvedSuccessTitle, AppText.approvedSuccessDesc);
    } catch (e) {
      Get.snackbar("Error", "Failed to approve: $e");
    }
  }

  Future<void> reject() async {
    try {
      final id = request['id'];
      if (id == null) return;

      await repo.rejectRequest(id, "Rejected by Admin");

      Get.back(result: true);
      Get.snackbar(AppText.requestRejected, AppText.requestRejectedDesc);
    } catch (e) {
      Get.snackbar("Error", "Failed to reject: $e");
    }
  }
}
