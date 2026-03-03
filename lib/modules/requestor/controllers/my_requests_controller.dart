import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/request_repository.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/date_helper.dart';

class MyRequestsController extends GetxController {
  final RequestRepository _repository =
      Get.find<RequestRepository>(); // Ensure ID is injected

  final currentTab = 0
      .obs; // 0: All, 1: Pending, 2: Approved, 3: Rejected, 4: Unpaid, 5: Clarification
  final isLoading = false.obs;
  final requestList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['filter'] == 'Pending') {
      currentTab.value = 1;
    }
    // Listen to tab changes to refetch
    ever(currentTab, (_) => fetchRequests());
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    try {
      String? status;
      String? paymentStatus;

      switch (currentTab.value) {
        case 1: // Pending
          status = 'pending';
          break;
        case 2: // Approved (Includes auto_approved)
          status = 'approved';
          break;
        case 3: // Rejected
          status = 'rejected';
          break;
        case 4: // Unpaid
          paymentStatus = 'pending';
          break;
        case 5: // Clarification
          status = 'clarification_required';
          break;
        default: // All
          break;
      }

      final rawRequests = await _repository.getMyRequests(
        status: status,
        paymentStatus: paymentStatus,
      );

      // Enhance with UI helpers (Icon, Color)
      requestList.value = rawRequests.map((req) {
        final category = req['category'] as String? ?? 'General';
        req['icon'] = _getCategoryIcon(category);
        req['iconColor'] = AppColors.primaryBlue; // Unified blue for now or map
        req['iconBg'] = AppColors.primaryBlue.withOpacity(0.1);
        req['date'] = DateHelper.formatDate(req['created_at']);
        req['title'] = req['purpose'] ?? req['title'] ?? 'Request';

        // Map receipt_url to attachments list for details view
        if (req['receipt_url'] != null &&
            req['receipt_url'].toString().isNotEmpty) {
          req['attachments'] = [
            {'file': req['receipt_url'], 'name': 'Receipt', 'size': 'Unknown'},
          ];
        }

        return req;
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch requests: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredRequests {
    if (searchQuery.value.isEmpty) {
      return requestList;
    }
    final lowerQuery = searchQuery.value.toLowerCase();
    return requestList
        .where(
          (r) =>
              (r['title']?.toString().toLowerCase().contains(lowerQuery) ??
                  false) ||
              (r['request_id']?.toString().toLowerCase().contains(lowerQuery) ??
                  false),
        )
        .toList();
  }

  void searchRequests(String query) {
    searchQuery.value = query;
  }

  void changeTab(int index) {
    if (currentTab.value != index) {
      currentTab.value = index;
    }
  }

  void viewDetails(Map<String, dynamic> request) {
    if (request['status'] == 'clarification_required') {
      Get.toNamed(AppRoutes.REQUESTOR_CLARIFICATION, arguments: request);
    } else {
      Get.toNamed(AppRoutes.REQUEST_DETAILS_READ, arguments: request);
    }
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('meal') || cat.contains('lunch'))
      return Icons.restaurant;
    if (cat.contains('travel') || cat.contains('flight')) return Icons.flight;
    if (cat.contains('transport') ||
        cat.contains('taxi') ||
        cat.contains('uber'))
      return Icons.directions_car;
    if (cat.contains('office') || cat.contains('supplies'))
      return Icons.shopping_bag; // Changed from shopping_cart for variety
    if (cat.contains('hotel') || cat.contains('lodging')) return Icons.hotel;
    return Icons.category;
  }
}
