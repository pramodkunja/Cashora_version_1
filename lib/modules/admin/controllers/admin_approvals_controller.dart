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

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _adminRepository = AdminRepository(Get.find<NetworkService>());
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
        _adminRepository.getOrgExpenses(status: 'clarification_required'),
        _adminRepository.getOrgExpenses(status: 'clarification_responded'),
      ]);

      approvedRequests.assignAll(results[0]);
      unpaidRequests.assignAll(results[1]);

      // Combine clarification required and responded
      final combinedClarification = <Map<String, dynamic>>[];
      combinedClarification.addAll(results[2]);
      combinedClarification.addAll(results[3]);
      
      // Sort by date descending
      combinedClarification.sort((a, b) {
         final dateA = a['created_at'] ?? a['date'] ?? '';
         final dateB = b['created_at'] ?? b['date'] ?? '';
         return dateB.compareTo(dateA);
      });
      
      clarificationRequests.assignAll(combinedClarification);

      print("Debugging Data Fetch:");
      print("Pending: ${pendingData.length}");
      print("Clarification Response Count: ${results[4].length}");
      if (results[4].isNotEmpty) {
        print("Sample Clarification Response: ${results[4].first}");
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToDetails(Map<String, dynamic> request) {
    // If status implies clarification, go to clarification view
    String status = request['status'] ?? '';
    if (status == 'clarification_required' ||
        status == 'clarification_responded') {
      Get.toNamed(AppRoutes.ADMIN_CLARIFICATION_STATUS, arguments: request);
    } else {
      Get.toNamed(AppRoutes.ADMIN_REQUEST_DETAILS, arguments: request);
    }
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
