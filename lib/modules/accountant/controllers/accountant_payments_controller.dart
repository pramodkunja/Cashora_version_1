import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/accountant_repository.dart';
import '../../../../data/repositories/payment_repository.dart'; // Added import
import '../../../../core/services/network_service.dart';
import '../../../../data/models/payment_response_model.dart';

class AccountantPaymentsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  late final AccountantRepository _repository;

  // Raw expense maps from the backend (shape matches the /my-requests response)
  final RxList<Map<String, dynamic>> pendingExpenses =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> completedExpenses =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    _repository = AccountantRepository(Get.find<NetworkService>());
    fetchPendingPayments();
    fetchCompletedPayments();

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        if (tabController.index == 0) fetchPendingPayments();
        else if (tabController.index == 1) fetchCompletedPayments();
      }
    });
  }

  Future<void> fetchPendingPayments() async {
    try {
      isLoading.value = true;
      final raw = await _repository.getPendingExpenses();
      pendingExpenses.value = raw;
    } catch (e) {
      print('Error fetching pending: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCompletedPayments() async {
    try {
      isLoading.value = true;
      final raw = await _repository.getCompletedExpenses(page: 1, size: 25);
      completedExpenses.value = raw;
    } catch (e) {
      print('Error fetching completed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.ACCOUNTANT_DASHBOARD);
        break;
      case 1:
        // Current
        break;
      case 2:
        // Get.toNamed(AppRoutes.ACCOUNTANT_REPORTS);
        break;
      case 3:
        Get.offNamed(AppRoutes.ACCOUNTANT_PROFILE);
        break;
    }
  }
}
