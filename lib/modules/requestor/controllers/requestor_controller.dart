import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/request_repository.dart';
import 'my_requests_controller.dart';

class RequestorController extends GetxController {
  final currentIndex = 0.obs;
  final RequestRepository _repository = Get.find<RequestRepository>();

  final pendingCount = 0.obs;

  // Dashboard-driven state (sourced from GET /requestor/dashboard)
  final recentRequests = <Map<String, dynamic>>[].obs;
  final amountSpent = 0.0.obs;
  final monthlyLimit = 0.0.obs;
  final progressRatio = 0.0.obs;
  final dashboardShortName = ''.obs;

  final isDashboardLoading = false.obs;
  final dashboardError = ''.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 1) {
      if (Get.isRegistered<MyRequestsController>()) {
        Get.find<MyRequestsController>().fetchRequests();
      }
    } else if (index == 0) {
      fetchDashboard();
    }
  }

  final userName = ''.obs;

  final showWelcome = true.obs;

  String get shortName {
    if (dashboardShortName.value.isNotEmpty) return dashboardShortName.value;

    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;

    if (user == null) return 'Requestor';

    if (user.firstName.isNotEmpty) {
      return user.firstName;
    }

    String name = user.name;
    if (name.isEmpty || name == 'Unknown') {
      name = user.email.isNotEmpty ? user.email : 'Requestor';
    }

    if (name.contains(' ')) {
      return name.split(' ').first;
    }
    return name;
  }

  @override
  void onInit() {
    super.onInit();
    final authService = Get.find<AuthService>();
    if (authService.currentUser.value != null) {
      userName.value = authService.currentUser.value!.name;
    } else {
      userName.value = 'Requestor';
    }

    Future.delayed(const Duration(seconds: 5), () {
      showWelcome.value = false;
    });

    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isDashboardLoading.value = true;
    dashboardError.value = '';
    try {
      final data = await _repository.getDashboard();

      final user = data['user'];
      if (user is Map && user['shortName'] != null) {
        dashboardShortName.value = user['shortName'].toString();
      }

      final monthly = data['monthlyExpense'];
      if (monthly is Map) {
        amountSpent.value = (monthly['amountSpent'] as num?)?.toDouble() ?? 0.0;
        monthlyLimit.value = (monthly['monthlyLimit'] as num?)?.toDouble() ?? 0.0;
        progressRatio.value =
            (monthly['progressRatio'] as num?)?.toDouble() ?? 0.0;
      }

      final pending = data['pendingApprovals'];
      if (pending is Map) {
        pendingCount.value = (pending['pendingCount'] as num?)?.toInt() ?? 0;
      }

      final recent = data['recentRequests'];
      if (recent is List) {
        recentRequests.assignAll(
          recent.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        );
      } else {
        recentRequests.clear();
      }
    } catch (e) {
      dashboardError.value =
          _extractErrorMessage(e, fallback: 'Failed to load dashboard');
    } finally {
      isDashboardLoading.value = false;
    }
  }

  /// Kept for backwards compatibility with existing callers.
  Future<void> fetchPendingCount() => fetchDashboard();

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
