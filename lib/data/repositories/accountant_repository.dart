import 'package:dio/dio.dart'
    show DioException, Options, ResponseType;
import 'package:flutter/foundation.dart';
import '../../core/services/network_service.dart';
import '../models/payment_response_model.dart';

class AccountantRepository {
  final NetworkService _networkService;

  AccountantRepository(this._networkService);

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _networkService.get('/accountant/dashboard');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching dashboard: $e');
      rethrow;
    }
  }

  /// POST /accountant/balance
  Future<Map<String, dynamic>> updateDailyBalance(double openingBalance) async {
    if (openingBalance < 0) {
      throw ArgumentError('openingBalance must be >= 0');
    }
    final response = await _networkService.post(
      '/accountant/balance',
      data: {'openingBalance': openingBalance},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getReportsSummary({int? month, int? year, String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;
      if (category != null && category.isNotEmpty && category != 'All Categories') {
        queryParams['category'] = category;
      }
      
      final response = await _networkService.get('/accountant/reports/summary', queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching reports summary: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSpendAnalytics({String? timeRange, String? department, String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (timeRange != null && timeRange.isNotEmpty) queryParams['time_range'] = timeRange;
      if (department != null && department.isNotEmpty && department != 'Department') queryParams['department'] = department;
      if (category != null && category.isNotEmpty && category != 'Category' && category != 'All Categories') queryParams['category'] = category;
      
      final response = await _networkService.get('/accountant/analytics/spend', queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching spend analytics: $e');
      rethrow;
    }
  }

  Future<List<int>> exportCsv({String? startDate, String? endDate, String? category}) async {
    return _downloadExport('/accountant/reports/export/csv', startDate, endDate, category);
  }

  Future<List<int>> exportPdf({String? startDate, String? endDate, String? category}) async {
    return _downloadExport('/accountant/reports/export/pdf', startDate, endDate, category);
  }

  Future<List<int>> _downloadExport(String path, String? startDate, String? endDate, String? category) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;
      if (category != null && category.isNotEmpty && category != 'All Categories') queryParams['category'] = category;

      final response = await _networkService.get(
        path,
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as List<int>;
    } catch (e) {
      if (kDebugMode) debugPrint('Error exporting $path: $e');
      rethrow;
    }
  }

  /// Returns the pending-payment expenses as raw Maps (paginated → items).
  Future<List<Map<String, dynamic>>> getPendingExpenses() async {
    try {
      final response = await _networkService.get(
        '/accountant/expenses/pending-payments',
      );
      final data = response.data as Map<String, dynamic>;
      final rawList =
          (data['items'] as List?) ??
          (data['payments'] as List?) ??
          (data['expenses'] as List?) ??
          [];
      return rawList.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching pending expenses: $e');
      rethrow;
    }
  }

  /// Returns completed/paid expenses as raw Maps.
  Future<List<Map<String, dynamic>>> getCompletedExpenses({int page = 1, int size = 25}) async {
    try {
      final response = await _networkService.get(
        '/accountant/expenses/paid',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final rawList =
          (data['items'] as List?) ??
          (data['payments'] as List?) ??
          (data['expenses'] as List?) ??
          [];
      return rawList.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching completed expenses: $e');
      rethrow;
    }
  }

  /// Legacy — kept for compatibility.
  Future<PaymentResponse> getPendingPayments() async {
    try {
      final response = await _networkService.get(
        '/accountant/expenses/pending-payments',
      );
      return PaymentResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching pending payments: $e');
      rethrow;
    }
  }
}


