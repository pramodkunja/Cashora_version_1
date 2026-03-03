import 'package:get/get.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../../../core/services/network_service.dart';

class AdminHistoryController extends GetxController {
  late final AdminRepository _adminRepository;
  final historyRequests = <Map<String, dynamic>>[].obs;
  final RxString selectedFilter = 'All'.obs;
  final RxMap<String, dynamic> _selectedRequest = <String, dynamic>{}.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _adminRepository = AdminRepository(Get.find<NetworkService>());
    fetchHistory();
  }

  Map<String, dynamic> get selectedRequest => _selectedRequest;

  List<Map<String, dynamic>> get filteredRequests {
    if (selectedFilter.value == 'All') {
      return historyRequests;
    }
    return historyRequests.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      if (selectedFilter.value == 'Approved')
        return status == 'approved' || status == 'auto_approved';
      if (selectedFilter.value == 'Rejected') return status == 'rejected';
      if (selectedFilter.value == 'Pending') return status == 'pending';
      if (selectedFilter.value == 'Clarified')
        return status == 'clarification_required';
      return false;
    }).toList();
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }

  void viewDetails(Map<String, dynamic> item) {
    _selectedRequest.value = item;
    Get.toNamed(AppRoutes.ADMIN_REQUEST_DETAILS, arguments: item);
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _adminRepository.getOrgExpenses(status: 'approved'),
        _adminRepository.getRejectedExpenses(),
        _adminRepository.getOrgExpenses(status: 'auto_approved'),
        _adminRepository.getOrgExpenses(status: 'pending'),
        _adminRepository.getOrgExpenses(status: 'clarification_required'),
      ]);

      final allHistory = results.expand((element) => element).toList();

      // Sort by updated_at or created_at desc
      allHistory.sort((a, b) {
        final dateStrA = a['updated_at'] ?? a['created_at'] ?? '';
        final dateStrB = b['updated_at'] ?? b['created_at'] ?? '';

        if (dateStrA.toString().isEmpty) return 1; // Push nulls to bottom
        if (dateStrB.toString().isEmpty) return -1;

        try {
          final dateA = DateTime.parse(dateStrA);
          final dateB = DateTime.parse(dateStrB);
          return dateB.compareTo(dateA);
        } catch (_) {
          return 0;
        }
      });

      historyRequests.assignAll(allHistory);
    } catch (e) {
      print("Error fetching history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
