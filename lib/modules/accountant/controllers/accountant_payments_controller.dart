import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/accountant_repository.dart';
// Added import
import '../../../../core/services/network_service.dart';

class AccountantPaymentsController extends GetxController {
  late final AccountantRepository _repository;

  final RxList<Map<String, dynamic>> pendingExpenses =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> completedExpenses =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;

  final pendingScroll = ScrollController();
  final completedScroll = ScrollController();

  /// First-load gate. Tab switches call [loadIfNeeded] so the network only
  /// fires once; pull-to-refresh and explicit refreshes should keep calling
  /// the raw [fetchPendingPayments] / [fetchCompletedPayments] directly.
  bool _hasLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _repository = AccountantRepository(Get.find<NetworkService>());
    loadIfNeeded();
  }

  /// Idempotent first-load entry point.
  void loadIfNeeded() {
    if (_hasLoaded) return;
    _hasLoaded = true;
    fetchPendingPayments();
    fetchCompletedPayments();
  }

  @override
  void onClose() {
    // Do not dispose ScrollControllers here to prevent "used after disposed" 
    // exceptions when views are still in the widget tree (e.g. TabBarView/IndexedStack)
    // pendingScroll.dispose();
    // completedScroll.dispose();
    super.onClose();
  }

  void resetScroll() {
    if (pendingScroll.hasClients) pendingScroll.jumpTo(0);
    if (completedScroll.hasClients) completedScroll.jumpTo(0);
  }

  Future<void> fetchPendingPayments() async {
    try {
      isLoading.value = true;
      final raw = await _repository.getPendingExpenses();
      pendingExpenses.value = raw;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching pending: $e');
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
      if (kDebugMode) debugPrint('Error fetching completed: $e');
    } finally {
      isLoading.value = false;
    }
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
