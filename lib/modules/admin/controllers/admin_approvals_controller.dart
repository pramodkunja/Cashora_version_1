import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Added for TabController
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_text.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../../../core/services/network_service.dart';

class AdminApprovalsController extends GetxController {
  late final AdminRepository _adminRepository;

  final pendingRequests = <Map<String, dynamic>>[].obs;
  final approvedRequests = <Map<String, dynamic>>[].obs;
  final unpaidRequests = <Map<String, dynamic>>[].obs;
  final clarificationRequests = <Map<String, dynamic>>[].obs;
  final rejectedRequests = <Map<String, dynamic>>[].obs;

  final isLoading = true.obs;

  // One scroll controller per tab
  final pendingScroll = ScrollController();
  final approvedScroll = ScrollController();
  final unpaidScroll = ScrollController();
  final clarificationScroll = ScrollController();
  final rejectedScroll = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _adminRepository = AdminRepository(Get.find<NetworkService>());
  }

  @override
  void onClose() {
    pendingScroll.dispose();
    approvedScroll.dispose();
    unpaidScroll.dispose();
    clarificationScroll.dispose();
    rejectedScroll.dispose();
    super.onClose();
  }

  void _resetAllScroll() {
    for (final c in [
      pendingScroll,
      approvedScroll,
      unpaidScroll,
      clarificationScroll,
      rejectedScroll,
    ]) {
      if (c.hasClients) c.jumpTo(0);
    }
  }

  void resetTab() {
    // Tab resetting is handled by UI or re-building logic if needed.
    // With DefaultTabController, programmatic reset requires context.
    // For now, we leave this empty as it's not critical for stability.
  }

  @override
  void onReady() {
    super.onReady();
    fetchAllRequests();
  }

  Future<void> fetchAllRequests() async {
    try {
      isLoading.value = true;

      // 1. Fetch Priority Items (Pending) First for immediate UI feedback
      final pendingData = await _adminRepository.getOrgExpenses(
        status: 'pending',
      );
      pendingRequests.assignAll(pendingData);

      // 2. Fetch others in background
      final results = await Future.wait([
        _adminRepository.getOrgExpenses(status: 'approved'),
        _adminRepository.getOrgExpenses(paymentStatus: 'pending'),
        _adminRepository.getOrgExpenses(status: 'clarification'),
        _adminRepository.getOrgExpenses(status: 'rejected'),
      ]);

      approvedRequests.assignAll(results[0]);
      unpaidRequests.assignAll(results[1]);

      // Assign Clarification requests directly
      clarificationRequests.assignAll(results[2]);
      
      // Assign Rejected requests
      rejectedRequests.assignAll(results[3]);

      if (kDebugMode) {
        debugPrint("Debugging Data Fetch:");
        debugPrint("Pending: ${pendingData.length}");
        debugPrint("Clarification Count: ${results[2].length}");
        if (results[2].isNotEmpty) {
          debugPrint("Sample Clarification: ${results[2].first}");
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> navigateToDetails(Map<String, dynamic> request) async {
    final status = (request['status'] ?? '').toString().toLowerCase();
    if (status.contains('clarification')) {
      await Get.toNamed(AppRoutes.ADMIN_CLARIFICATION_STATUS, arguments: request);
    } else {
      await Get.toNamed(AppRoutes.ADMIN_REQUEST_DETAILS, arguments: request);
    }
    // Reset scroll + refresh on return
    _resetAllScroll();
    await fetchAllRequests();
  }

  String getInitials(String name) {
    if (name.isEmpty) return '??';
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
