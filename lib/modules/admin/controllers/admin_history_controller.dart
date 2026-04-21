import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../../../core/services/network_service.dart';

class AdminHistoryController extends GetxController {
  late final AdminRepository _adminRepository;
  final historyRequests = <Map<String, dynamic>>[].obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxMap<String, dynamic> _selectedRequest = <String, dynamic>{}.obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _adminRepository = AdminRepository(Get.find<NetworkService>());
    fetchHistory();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollToTop() {
    if (scrollController.hasClients) scrollController.jumpTo(0);
  }

  Map<String, dynamic> get selectedRequest => _selectedRequest;

  List<Map<String, dynamic>> get filteredRequests => historyRequests;

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    _scrollToTop();
    fetchHistory();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    fetchHistory();
  }

  Future<void> viewDetails(Map<String, dynamic> item) async {
    _selectedRequest.value = item;
    final status = (item['status'] ?? '').toString().toLowerCase();
    if (status.contains('clarification')) {
      await Get.toNamed(AppRoutes.ADMIN_CLARIFICATION_STATUS, arguments: item);
    } else {
      await Get.toNamed(AppRoutes.ADMIN_REQUEST_DETAILS, arguments: item);
    }
    _scrollToTop();
    await fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Backend /admin/history status filter: All | approved | auto_approved | rejected | clarification
      // "All" is omitted so the backend returns every record.
      String? statusParam;
      switch (selectedFilter.value) {
        case 'All':
          statusParam = null;
          break;
        case 'Approved':
          statusParam = 'approved';
          break;
        case 'Rejected':
          statusParam = 'rejected';
          break;
        case 'Clarified':
        case 'Clarification':
          statusParam = 'clarification';
          break;
        case 'Auto Approved':
          statusParam = 'auto_approved';
          break;
        default:
          statusParam = null;
      }

      final results = await _adminRepository.getHistory(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        status: statusParam,
      );

      results.sort((a, b) {
        final dateStrA = a['updated_at'] ?? '';
        final dateStrB = b['updated_at'] ?? '';
        if (dateStrA.toString().isEmpty) return 1;
        if (dateStrB.toString().isEmpty) return -1;
        try {
          final dateA = DateTime.parse(dateStrA);
          final dateB = DateTime.parse(dateStrB);
          return dateB.compareTo(dateA);
        } catch (_) {
          return 0;
        }
      });

      historyRequests.assignAll(results);
    } catch (e) {
      errorMessage.value =
          _extractErrorMessage(e, fallback: 'Failed to load history');
    } finally {
      isLoading.value = false;
    }
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
}
