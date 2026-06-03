import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/network_service.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../profile/controllers/profile_controller.dart';

import 'admin_approvals_controller.dart';
import 'admin_history_controller.dart';

class AdminDashboardController extends GetxController {
  late final AdminRepository _adminRepository;

  final count = 0.obs;

  // Tab index for bottom bar
  final currentIndex = 0.obs;

  // Dashboard data from GET /admin/dashboard
  final dashboardShortName = ''.obs;
  final pendingRequestsCount = 0.obs;
  final inClarificationCount = 0.obs;
  final approvedAmount = 0.0.obs;
  final totalDepartments = 0.obs;
  final activeDepartments = 0.obs;
  final unassignedUsers = 0.obs;

  // Approver-specific stats from GET /approver/dashboard-stats.
  // Shown as summary cards at the top of the approver dashboard.
  final approverPendingCount = 0.obs;
  final approverApprovedAmount = 0.0.obs;
  final hasApproverStats = false.obs;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  String get shortName {
    if (dashboardShortName.value.isNotEmpty) return dashboardShortName.value;

    final user = Get.find<AuthService>().currentUser.value;
    if (user == null) return 'Approver';

    if (user.firstName.isNotEmpty) {
      return user.firstName;
    }

    String name = user.name;
    if (name.isEmpty || name == 'Unknown') {
      name = user.email.isNotEmpty ? user.email : 'Approver';
    }

    if (name.contains(' ')) {
      return name.split(' ').first;
    }
    return name;
  }

  final showWelcome = true.obs;

  @override
  void onInit() {
    super.onInit();
    _adminRepository = AdminRepository(Get.find<NetworkService>());
    Future.delayed(const Duration(seconds: 5), () {
      showWelcome.value = false;
    });
    fetchDashboard();
    fetchApproverStats();
  }

  Future<void> fetchApproverStats() async {
    try {
      final data = await _adminRepository.getApproverDashboardStats();
      approverPendingCount.value =
          (data['pending_count'] as num?)?.toInt() ?? 0;
      approverApprovedAmount.value =
          (data['total_approved_amount'] as num?)?.toDouble() ?? 0.0;
      hasApproverStats.value = data.isNotEmpty;
    } catch (_) {
      // Non-blocking: dashboard still renders without the summary cards.
      hasApproverStats.value = false;
    }
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _adminRepository.getDashboard();

      final user = data['user'];
      if (user is Map && user['shortName'] != null) {
        dashboardShortName.value = user['shortName'].toString();
      }

      final overview = data['overview'];
      if (overview is Map) {
        pendingRequestsCount.value =
            (overview['pendingRequestsCount'] as num?)?.toInt() ?? 0;
        // Backend may emit camelCase (`inClarificationCount`) or snake_case
        // (`in_clarification_count`) depending on serializer config.
        inClarificationCount.value =
            ((overview['inClarificationCount'] ??
                        overview['in_clarification_count']) as num?)
                    ?.toInt() ??
                0;
        approvedAmount.value =
            (overview['approvedAmount'] as num?)?.toDouble() ?? 0.0;
      }

      final dept = data['departmentSummary'];
      if (dept is Map) {
        totalDepartments.value =
            (dept['totalDepartments'] as num?)?.toInt() ?? 0;
        activeDepartments.value =
            (dept['activeDepartments'] as num?)?.toInt() ?? 0;
        unassignedUsers.value =
            (dept['unassignedUsers'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      errorMessage.value =
          _extractErrorMessage(e, fallback: 'Failed to load dashboard');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 0) {
      fetchDashboard();
      fetchApproverStats();
    } else if (index == 1) {
      if (Get.isRegistered<AdminApprovalsController>()) {
        final ctrl = Get.find<AdminApprovalsController>();
        ctrl.fetchAllRequests();
        ctrl.resetTab();
      }
    } else if (index == 2) {
      // History tab — refetch /admin/history every time the tab is opened
      // so newly-approved/rejected/clarified items appear without the user
      // having to drill into a record first.
      if (Get.isRegistered<AdminHistoryController>()) {
        Get.find<AdminHistoryController>().fetchHistory();
      }
    } else if (index == 3) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile();
      }
    }
  }

  void navigateToApprovals() {
    changeTab(1);
  }

  static String _extractErrorMessage(Object e, {required String fallback}) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
      if (data is Map && data['message'] != null) return data['message'].toString();
      final code = e.response?.statusCode;
      if (code == 401) return 'Session expired. Please log in again.';
      if (code == 403) return 'You do not have access to this resource.';
    }
    return fallback;
  }
}
