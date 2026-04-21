import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../utils/app_colors.dart';
import '../views/widgets/update_balances_dialog.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/network_service.dart';
import '../../../../data/repositories/accountant_repository.dart';
import '../../../../data/models/accountant_dashboard_model.dart';
import '../controllers/accountant_profile_controller.dart';
import '../controllers/accountant_payments_controller.dart';

class AccountantDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  late final AccountantRepository _repository;

  final Rx<AccountantDashboardModel?> dashboardData =
      Rx<AccountantDashboardModel?>(null);
  final RxBool isDashboardLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String get shortName {
    if (dashboardData.value != null && dashboardData.value!.user.shortName.isNotEmpty) {
      return dashboardData.value!.user.shortName;
    }
    final user = _authService.currentUser.value;
    if (user == null) return 'Approver';

    // Use firstName if available, otherwise fall back to name logic
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
    _repository = AccountantRepository(Get.find<NetworkService>());
  }

  @override
  void onReady() {
    super.onReady();
    _checkDailyBalanceUpdate();
    fetchDashboard();

    // Auto-hide welcome message after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      showWelcome.value = false;
    });
  }

  Future<void> fetchDashboard() async {
    isDashboardLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _repository.getDashboard();
      dashboardData.value = AccountantDashboardModel.fromJson(res);
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data: $e';
      if (kDebugMode) debugPrint(errorMessage.value);
    } finally {
      isDashboardLoading.value = false;
    }
  }

  Future<void> _checkDailyBalanceUpdate() async {
    // 1. Get today's date formatted as YYYY-MM-DD
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // 2. Check Storage
    const storage = FlutterSecureStorage();
    final lastUpdate = await storage.read(key: 'last_balance_update_date');

    if (lastUpdate != todayStr) {
      Future.delayed(const Duration(seconds: 1), () {
        _showUpdateBalanceDialog(todayStr, storage);
      });
    }
  }

  void _showUpdateBalanceDialog(String todayStr, FlutterSecureStorage storage) {
    final amountController = TextEditingController();

    Get.dialog(
      UpdateBalancesDialog(
        controller: amountController,
        onSave: () async {
          final raw = amountController.text.trim();
          final parsed = double.tryParse(raw);
          if (parsed == null || parsed < 0) {
            Get.snackbar(
              'Invalid amount',
              'Please enter a valid non-negative opening balance.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: Colors.white,
              margin: const EdgeInsets.all(20),
            );
            return;
          }

          try {
            await _repository.updateDailyBalance(parsed);
            await storage.write(
              key: 'last_balance_update_date',
              value: todayStr,
            );

            Get.back();
            await fetchDashboard();

            Get.snackbar(
              'Success',
              'Opening balance updated for today',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.successGreen,
              colorText: Colors.white,
              margin: const EdgeInsets.all(20),
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              _extractErrorMessage(e, fallback: 'Failed to update balance'),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: Colors.white,
              margin: const EdgeInsets.all(20),
            );
          }
        },
        onCancel: () {
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }

  static String _extractErrorMessage(Object e, {required String fallback}) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
      if (data is Map && data['message'] != null) return data['message'].toString();
      final code = e.response?.statusCode;
      if (code == 400) return 'Invalid opening balance.';
      if (code == 401) return 'Session expired. Please log in again.';
      if (code == 403) return 'You do not have accountant access.';
    }
    return fallback;
  }

  final rxIndex = 0.obs;

  void changeTabIndex(int index) {
    rxIndex.value = index;
  }

  void navigateToPayments() {
    changeTabIndex(1);
    // Trigger refresh for Payments
    if (Get.isRegistered<AccountantPaymentsController>()) {
      Get.find<AccountantPaymentsController>().fetchPendingPayments();
    }
  }

  void onBottomNavTap(int index) {
    rxIndex.value = index;
    if (index == 0) {
      fetchDashboard();
    } else if (index == 1) {
      // Payments Tab
      if (Get.isRegistered<AccountantPaymentsController>()) {
        Get.find<AccountantPaymentsController>().fetchPendingPayments();
      }
    } else if (index == 3) {
      // Profile Tab
      if (Get.isRegistered<AccountantProfileController>()) {
        Get.find<AccountantProfileController>().fetchProfile();
      }
    }
  }
}

