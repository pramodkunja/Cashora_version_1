import 'package:dio/dio.dart' show DioException, Options, ResponseType;
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

  /// GET /accountant/transactions/today
  ///
  /// Returns today's transactions for the View All screen. Response shape:
  ///   `{ date, total_in, total_out, net, count, transactions[] }`
  Future<Map<String, dynamic>> getTodayTransactions() async {
    final response =
        await _networkService.get('/accountant/transactions/today');
    final data = response.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    // Tolerate a bare-list response too, in case backend returns just the
    // array — wrap it so the caller has a single contract.
    if (data is List) {
      return {
        'transactions': List<Map<String, dynamic>>.from(data),
      };
    }
    return const {};
  }

  /// POST /accountant/process-payout
  ///
  /// Marks an expense as paid out. Backend body:
  ///   `{ expense_id: int, reference_number?: string, accountant_note?: string }`
  Future<Map<String, dynamic>> processPayout({
    required int expenseId,
    String? referenceNumber,
    String? accountantNote,
  }) async {
    final body = <String, dynamic>{'expense_id': expenseId};
    if (referenceNumber != null && referenceNumber.trim().isNotEmpty) {
      body['reference_number'] = referenceNumber.trim();
    }
    if (accountantNote != null && accountantNote.trim().isNotEmpty) {
      body['accountant_note'] = accountantNote.trim();
    }
    final response = await _networkService.post(
      '/accountant/process-payout',
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /accountant/balance
  ///
  /// Set or update today's opening balance (and optionally the closing
  /// balance + note). The backend recomputes derived values.
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

  /// POST /accountant/balance
  ///
  /// Richer variant that accepts an explicit closing balance and an
  /// optional note. The accountant uses this from the Manage Balances
  /// screen to overwrite a particular day's record.
  Future<Map<String, dynamic>> setBalance({
    required double openingBalance,
    double? closingBalance,
    String? note,
    String? date, // ISO 'YYYY-MM-DD' — defaults to today on the backend
  }) async {
    if (openingBalance < 0) {
      throw ArgumentError('openingBalance must be >= 0');
    }
    if (closingBalance != null && closingBalance < 0) {
      throw ArgumentError('closingBalance must be >= 0');
    }
    final body = <String, dynamic>{'openingBalance': openingBalance};
    if (closingBalance != null) body['closingBalance'] = closingBalance;
    if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();
    if (date != null && date.trim().isNotEmpty) body['date'] = date.trim();
    final response =
        await _networkService.post('/accountant/balance', data: body);
    return response.data as Map<String, dynamic>;
  }

  /// GET /accountant/balance
  ///
  /// Returns the current (today's) balance snapshot:
  ///   { date, opening_balance, closing_balance, amount_in, amount_out,
  ///     last_updated_at, note }
  Future<Map<String, dynamic>> getCurrentBalance() async {
    final response = await _networkService.get('/accountant/balance');
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
  }

  /// GET /accountant/balance/history
  ///
  /// Returns a list of balance snapshots, newest first. Each item:
  ///   { date, opening_balance, closing_balance, amount_in, amount_out,
  ///     updated_by, updated_at, note }
  Future<List<Map<String, dynamic>>> getBalanceHistory({
    int page = 1,
    int size = 30,
  }) async {
    final response = await _networkService.get(
      '/accountant/balance/history',
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data;
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map && data['items'] is List) {
      return List<Map<String, dynamic>>.from(data['items']);
    }
    return const [];
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

  /// GET /accountant/analytics/spend
  ///
  /// Backend accepts query: `time_range` ∈ {30d, 90d, 180d, 1y},
  /// `department`, `category`. The UI passes human-readable labels
  /// ("This Month", "Last 3 Months", placeholder "Department" / "Category"),
  /// so we normalize them here.
  Future<Map<String, dynamic>> getSpendAnalytics({String? timeRange, String? department, String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      final mappedRange = _mapTimeRange(timeRange);
      if (mappedRange != null) queryParams['time_range'] = mappedRange;
      if (department != null &&
          department.isNotEmpty &&
          department != 'Department' &&
          department != 'All Departments') {
        queryParams['department'] = department;
      }
      if (category != null &&
          category.isNotEmpty &&
          category != 'Category' &&
          category != 'All Categories') {
        queryParams['category'] = category;
      }

      final response = await _networkService.get(
        '/accountant/analytics/spend',
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching spend analytics: $e');
      rethrow;
    }
  }

  /// Map UI labels to the backend's strict `time_range` enum.
  /// Returns `null` for unrecognized values so the param is omitted (which
  /// makes the backend apply its default rather than 400).
  static String? _mapTimeRange(String? label) {
    if (label == null || label.trim().isEmpty) return null;
    switch (label.trim().toLowerCase()) {
      case 'this month':
      case 'last month':
      case 'last 30 days':
      case '30 days':
      case '30d':
        return '30d';
      case 'last 3 months':
      case 'last 90 days':
      case '90 days':
      case '90d':
        return '90d';
      case 'last 6 months':
      case 'last 180 days':
      case '180 days':
      case '180d':
        return '180d';
      case 'last year':
      case 'last 12 months':
      case 'this year':
      case '1y':
        return '1y';
      default:
        return null;
    }
  }

  /// GET /accountant/analytics/spend-by-category
  ///
  /// Lightweight `{category: amount}` map. Used by simpler widgets that only
  /// need a breakdown by category.
  Future<Map<String, double>> getSpendByCategory() async {
    try {
      final response = await _networkService.get(
        '/accountant/analytics/spend-by-category',
      );
      final raw = response.data;
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
      }
      return const {};
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching spend-by-category: $e');
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
      if (category != null && category.isNotEmpty && category != 'All Categories') {
        queryParams['category'] = category;
      }

      final response = await _networkService.get(
        path,
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.bytes,
          // Accept any 2xx and let us see 4xx bodies for debugging instead
          // of throwing through Dio's default validateStatus.
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        final body = response.data is List<int>
            ? String.fromCharCodes(response.data as List<int>)
            : response.data.toString();
        if (kDebugMode) {
          debugPrint('Export $path failed ${response.statusCode}: $body');
        }
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Export failed (${response.statusCode}): $body',
        );
      }

      final data = response.data;
      if (data is List<int>) return data;
      if (data is String) return data.codeUnits;
      throw StateError('Unexpected export payload type: ${data.runtimeType}');
    } catch (e) {
      if (kDebugMode) debugPrint('Error exporting $path: $e');
      rethrow;
    }
  }

  /// Backend canonical response shape for paginated payment lists is
  /// `{ total, page, size, items: [...] }`. Anything else (e.g. a top-level
  /// list, a `payments` alias) is treated as a fallback only.
  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is Map<String, dynamic>) {
      final raw = data['items'] as List?;
      if (raw != null) return raw.cast<Map<String, dynamic>>();
    }
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  /// Returns the pending-payment expenses as raw Maps (paginated → items).
  Future<List<Map<String, dynamic>>> getPendingExpenses() async {
    try {
      final response = await _networkService.get(
        '/accountant/expenses/pending-payments',
      );
      return _extractItems(response.data);
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
      return _extractItems(response.data);
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching completed expenses: $e');
      rethrow;
    }
  }

  /// Typed wrapper around getPendingExpenses for callers that want the
  /// PaymentResponse pagination envelope.
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


