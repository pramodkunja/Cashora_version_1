import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/request_repository.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/date_helper.dart';

class MyRequestsController extends GetxController {
  final RequestRepository _repository =
      Get.find<RequestRepository>(); // Ensure ID is injected

  final currentTab = 0.obs;
  final isLoading = false.obs;
  final requestList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;

  // Scroll controller for list — used to reset scroll on return
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['filter'] == 'Pending') {
      currentTab.value = 1;
    }
    ever(currentTab, (_) {
      fetchRequests();
      _scrollToTop();
    });
  }

  @override
  void onClose() {
    // Do not dispose ScrollControllers here to prevent "used after disposed" exceptions
    // scrollController.dispose();
    super.onClose();
  }

  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    try {
      // Backend /requestor/requests status filter labels:
      // All | Pending | Clarification | Approved | Rejected | Unpaid
      String? status;
      switch (currentTab.value) {
        case 1:
          status = 'Pending';
          break;
        case 2:
          status = 'Approved';
          break;
        case 3:
          status = 'Rejected';
          break;
        case 4:
          status = 'Unpaid';
          break;
        case 5:
          status = 'Clarification';
          break;
        default:
          status = 'All';
      }

      final rawRequests = await _repository.getMyRequests(
        status: status,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      // Enhance with UI helpers (Icon, Color)
      requestList.value = rawRequests.map((req) {
        final category = req['category'] as String? ?? 'General';
        req['icon'] = _getCategoryIcon(category);
        req['iconColor'] = AppColors.primaryBlue;
        req['iconBg'] = AppColors.primaryBlue.withValues(alpha: 0.1);
        // Backend shape: { date: ISO string }. Fallback to created_at for legacy.
        req['date'] = DateHelper.formatDate(req['date'] ?? req['created_at']);
        req['title'] = req['purpose'] ?? req['title'] ?? 'Request';

        // Map receipt_url to attachments list for details view
        req['attachments'] = [];
        if (req['receipt_url'] != null &&
            req['receipt_url'].toString().isNotEmpty) {
          req['attachments'].add({'file': req['receipt_url'], 'name': 'Receipt', 'size': 'Unknown'});
        }
        if (req['payment_qr_url'] != null &&
            req['payment_qr_url'].toString().isNotEmpty) {
          req['attachments'].add({'file': req['payment_qr_url'], 'name': 'QR Code', 'size': 'Unknown'});
        }

        return req;
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        _extractErrorMessage(e, fallback: 'Failed to fetch requests'),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search is handled server-side via the `search` query param.
  List<Map<String, dynamic>> get filteredRequests => requestList;

  void searchRequests(String query) {
    searchQuery.value = query;
    fetchRequests();
  }

  static String _extractErrorMessage(Object e, {required String fallback}) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
      if (data is Map && data['message'] != null) return data['message'].toString();
      final code = e.response?.statusCode;
      if (code == 401) return 'Session expired. Please log in again.';
      if (code == 403) return 'You do not have access to this resource.';
      if (code == 400) return 'Invalid filter values.';
    }
    return fallback;
  }

  void changeTab(int index) {
    if (currentTab.value != index) {
      currentTab.value = index;
    }
  }

  Future<void> viewDetails(Map<String, dynamic> request) async {
    if (request['status'] == 'clarification') {
      await Get.toNamed(AppRoutes.REQUESTOR_CLARIFICATION, arguments: request);
    } else {
      await Get.toNamed(AppRoutes.REQUEST_DETAILS_READ, arguments: request);
    }
    // Reset scroll + refresh list when returning
    _scrollToTop();
    fetchRequests();
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('meal') || cat.contains('lunch')) {
      return Icons.restaurant;
    }
    if (cat.contains('travel') || cat.contains('flight')) return Icons.flight;
    if (cat.contains('transport') ||
        cat.contains('taxi') ||
        cat.contains('uber')) {
      return Icons.directions_car;
    }
    if (cat.contains('office') || cat.contains('supplies')) {
      return Icons.shopping_bag; // Changed from shopping_cart for variety
    }
    if (cat.contains('hotel') || cat.contains('lodging')) return Icons.hotel;
    return Icons.category;
  }
}
