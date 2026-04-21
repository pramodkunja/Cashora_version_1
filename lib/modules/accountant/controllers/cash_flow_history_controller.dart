import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/network_service.dart';
import '../../../../data/repositories/accountant_repository.dart';

class CashFlowHistoryController extends GetxController {
  late final AccountantRepository _repository;

  // 0: This Month, 1: Last 3 Months, 2: Custom
  final selectedFilter = 0.obs;

  final transactions = <Map<String, dynamic>>[].obs;
  final totalExpenses = 0.0.obs;
  final monthYear = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _repository = AccountantRepository(Get.find<NetworkService>());
    fetch();
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final now = DateTime.now();
      int? month;
      int? year;

      switch (selectedFilter.value) {
        case 0: // This Month
          month = now.month;
          year = now.year;
          break;
        case 1: // Last 3 Months — backend supports single month, default to last month
          final last = DateTime(now.year, now.month - 1, 1);
          month = last.month;
          year = last.year;
          break;
        case 2: // Custom — leave unset; backend defaults to current month
          break;
      }

      final data = await _repository.getReportsSummary(
        month: month,
        year: year,
      );

      final summary = data['previewSummary'];
      if (summary is Map) {
        monthYear.value = (summary['monthYear'] ?? '').toString();
        totalExpenses.value =
            (summary['totalExpenses'] as num?)?.toDouble() ?? 0.0;
        final tx = summary['transactions'];
        if (tx is List) {
          transactions.assignAll(
            tx.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
          );
        } else {
          transactions.clear();
        }
      } else {
        transactions.clear();
        totalExpenses.value = 0.0;
      }
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
      if (code == 403) return 'You do not have accountant access.';
      if (code == 400) return 'Invalid filter values.';
    }
    return fallback;
  }
}
