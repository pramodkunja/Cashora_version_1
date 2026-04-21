import 'package:dio/dio.dart';
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
      final data = {'action': action};
      if (reason != null) {
        data['rejection_reason'] = reason;
      }

      await _networkService.post(
        '/approver/expenses/$expenseId/decision',
        data: data,
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

  Future<void> askClarification(int id, String message) async {
    try {
      await _networkService.post(
        '/approver/ask-clarification',
        data: {'expense_id': id, 'question': message},
      );
    } catch (e) {
      if (kDebugMode) debugPrint("Error asking clarification: $e");
      rethrow;
    }
  }
}
