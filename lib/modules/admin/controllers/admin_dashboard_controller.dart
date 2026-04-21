import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/network_service.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../profile/controllers/profile_controller.dart';

import 'admin_approvals_controller.dart';

class AdminDashboardController extends GetxController {
  late final AdminRepository _adminRepository;

  final count = 0.obs;

  // Tab index for bottom bar
  final currentIndex = 0.obs;

  // Dashboard data from GET /admin/dashboard
  final dashboardShortName = ''.obs;
  final pendingRequestsCount = 0.obs;
  final approvedAmount = 0.0.obs;
  final totalDepartments = 0.obs;
  final activeDepartments = 0.obs;
  final unassignedUsers = 0.obs;

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
    } else if (index == 1) {
      if (Get.isRegistered<AdminApprovalsController>()) {
        final ctrl = Get.find<AdminApprovalsController>();
        ctrl.fetchAllRequests();
        ctrl.resetTab();
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
