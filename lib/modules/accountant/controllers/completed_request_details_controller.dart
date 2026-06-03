import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/services/network_service.dart';
import '../../../data/repositories/request_repository.dart';

/// Backs the completed-payment detail screen.
///
/// Lifecycle:
///   1. `onInit` seeds `paymentDetails` from `Get.arguments` so the
///      screen renders the cached row immediately — no spinner, no
///      blank screen, no layout jump.
///   2. Right after the first frame, fires off
///      `GET /requestor/requests/{id}` (the same endpoint the requestor
///      flow uses for its detail refresh) to pull the full request
///      shape (approved_at, paid_at, audit_trail, payment_method,
///      transaction_reference, etc.) and merges it over the cached row.
///   3. If the call fails (network / 403 / 404) the screen keeps
///      showing the cached row — no error banner, just a debug log.
class CompletedRequestDetailsController extends GetxController {
  final isLoading = false.obs;
  final paymentDetails = <String, dynamic>{}.obs;
  final errorMessage = ''.obs;

  late final RequestRepository _repository;

  @override
  void onInit() {
    super.onInit();
    // RequestRepository is registered by the requestor binding, but the
    // accountant flow never goes through that binding. Lazy-put a
    // singleton on first access so both flows share one instance.
    if (!Get.isRegistered<RequestRepository>()) {
      Get.put<RequestRepository>(
        RequestRepository(Get.find<NetworkService>()),
        permanent: true,
      );
    }
    _repository = Get.find<RequestRepository>();

    final args = Get.arguments;
    if (args is Map) {
      paymentDetails.value = Map<String, dynamic>.from(args);
    } else {
      errorMessage.value = 'No payment details provided';
      return;
    }

    // Refresh with the canonical backend shape on the next frame. Using
    // a microtask delay means the initial render uses the cached row;
    // by the time this fires we're already on screen.
    Future.microtask(_refresh);
  }

  Future<void> _refresh() async {
    final raw =
        paymentDetails['id'] ?? paymentDetails['request_id'];
    if (raw == null) return;
    final id = raw.toString();
    if (id.isEmpty) return;

    isLoading.value = true;
    try {
      // Same endpoint the requestor's RequestDetailsReadView uses.
      // Backend accepts numeric DB id OR string request id.
      final fresh = await _repository.getRequestById(id);
      // Merge: fresh values override cached, but any cache-only field
      // (e.g. icon hints injected by the list) is preserved.
      paymentDetails.value = {
        ...paymentDetails,
        ...fresh,
      };
    } catch (e) {
      // Silent fallback — keep showing cached data.
      if (kDebugMode) {
        debugPrint('[completed_request_details] refresh failed id=$id err=$e');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
