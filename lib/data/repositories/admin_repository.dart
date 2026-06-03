import 'package:flutter/foundation.dart';
import '../../core/services/network_service.dart';

class AdminRepository {
  final NetworkService _networkService;

  AdminRepository(this._networkService);

  /// GET /admin/dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _networkService.get('/admin/dashboard');
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Invalid dashboard response');
  }

  /// GET /approver/dashboard-stats
  ///
  /// Returns `{ pending_count, total_approved_amount }` for the approver
  /// dashboard summary cards.
  Future<Map<String, dynamic>> getApproverDashboardStats() async {
    final response = await _networkService.get('/approver/dashboard-stats');
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return const {};
  }

  /// GET /admin/history
  Future<List<Map<String, dynamic>>> getHistory({
    String? search,
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _networkService.get(
      '/admin/history',
      queryParameters: queryParams,
    );
    if (response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getOrgExpenses({
    String? status,
    String? paymentStatus,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;

      final response = await _networkService.get(
        '/approver/org-expenses',
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint("Error fetching org expenses: $e");
      rethrow; // Or return empty list based on error handling policy
    }
  }

  Future<List<Map<String, dynamic>>> getRejectedExpenses() async {
    return await getOrgExpenses(status: 'rejected');
  }

  Future<void> submitDecision(
    dynamic id,
    String action, {
    String? reason,
  }) async {
    try {
      final expenseId = id is int ? id : int.parse(id.toString());
      await _networkService.post(
        '/approver/expenses/$expenseId/decision',
        data: {
          'action': action.toLowerCase().trim(),
          'rejection_reason': reason?.trim(),
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint("Error submitting decision: $e");
      rethrow;
    }
  }

  Future<void> approveRequest(dynamic id) async {
    await submitDecision(id, 'approve');
  }

  Future<void> rejectRequest(dynamic id, String reason) async {
    await submitDecision(id, 'reject', reason: reason);
  }

  /// GET /approver/history/{expense_id}
  ///
  /// Returns the clarification thread for the approver-side view of an
  /// expense. Tolerates every shape FastAPI may emit:
  ///   - bare list:                   `[ {…}, {…} ]`
  ///   - wrapped under `history`:     `{ "history": [ … ] }`
  ///   - wrapped under `clarifications`: `{ "clarifications": [ … ] }`
  ///   - wrapped under `data`:         `{ "data": [ … ] }`
  ///   - any first List value in a map (last-resort scan)
  Future<List<Map<String, dynamic>>> getApproverClarificationHistory(int expenseId) async {
    try {
      final response = await _networkService.get('/approver/history/$expenseId');
      final data = response.data;
      if (kDebugMode) {
        debugPrint('[ClarificationRepo] /approver/history/$expenseId → type=${data.runtimeType}');
        debugPrint('[ClarificationRepo] body: $data');
      }

      List<dynamic>? rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map) {
        for (final key in const ['history', 'clarifications', 'data', 'items', 'results']) {
          if (data[key] is List) {
            rawList = data[key] as List;
            break;
          }
        }
        // Last resort: any value that's a List of Maps.
        rawList ??= data.values.whereType<List>().firstWhere(
              (l) => l.isNotEmpty && l.first is Map,
              orElse: () => const [],
            );
      }

      if (rawList == null || rawList.isEmpty) return const [];
      return rawList
          .whereType<Map>()
          .map<Map<String, dynamic>>((m) => Map<String, dynamic>.from(m))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching clarification history: $e');
      rethrow;
    }
  }

  Future<void> askClarification(int id, String message) async {
    try {
      await _networkService.post(
        '/approver/ask-clarification',
        data: {
          'expense_id': id, 
          'question': message.trim(),
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint("Error asking clarification: $e");
      rethrow;
    }
  }
}
