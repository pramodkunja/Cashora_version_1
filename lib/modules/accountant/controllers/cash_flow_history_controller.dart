import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/network_service.dart';
import '../../../../data/repositories/accountant_repository.dart';

/// Backs the "Today's Transactions" view-all screen on the accountant
/// home. Calls `GET /accountant/transactions/today` (the new endpoint
/// requested in MISSING_FIELDS.md Appendix A).
class CashFlowHistoryController extends GetxController {
  late final AccountantRepository _repository;

  final transactions = <Map<String, dynamic>>[].obs;

  final date = ''.obs;
  final totalIn = 0.0.obs;
  final totalOut = 0.0.obs;
  final net = 0.0.obs;
  final count = 0.obs;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _repository = AccountantRepository(Get.find<NetworkService>());
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repository.getTodayTransactions();

      date.value = data['date']?.toString() ?? '';
      totalIn.value = (data['total_in'] as num?)?.toDouble() ?? 0.0;
      totalOut.value = (data['total_out'] as num?)?.toDouble() ?? 0.0;
      net.value = (data['net'] as num?)?.toDouble() ??
          (totalIn.value - totalOut.value);
      count.value = (data['count'] as num?)?.toInt() ?? 0;

      final rows = data['transactions'];
      if (rows is List) {
        transactions.assignAll(
          rows.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        );
      } else {
        transactions.clear();
      }
    } catch (e) {
      errorMessage.value =
          _extractErrorMessage(e, fallback: 'Failed to load transactions');
      if (kDebugMode) debugPrint('[cash_flow_history] fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  static String _extractErrorMessage(Object e, {required String fallback}) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      final code = e.response?.statusCode;
      if (code == 401) return 'Session expired. Please log in again.';
      if (code == 403) return 'You do not have accountant access.';
      if (code == 404) return 'Today\'s transactions endpoint not available yet.';
    }
    return fallback;
  }
}
