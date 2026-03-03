import 'package:dio/dio.dart'
    show DioException; // keep Dio for type use only
import '../../core/services/network_service.dart';
import '../models/payment_response_model.dart';

class AccountantRepository {
  final NetworkService _networkService;

  AccountantRepository(this._networkService);

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
      print('Error fetching pending expenses: $e');
      rethrow;
    }
  }

  /// Returns completed/paid expenses as raw Maps.
  Future<List<Map<String, dynamic>>> getCompletedExpenses() async {
    try {
      final response = await _networkService.get(
        '/accountant/expenses/completed',
      );
      final data = response.data as Map<String, dynamic>;
      final rawList =
          (data['items'] as List?) ??
          (data['payments'] as List?) ??
          (data['expenses'] as List?) ??
          [];
      return rawList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching completed expenses: $e');
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
      print('Error fetching pending payments: $e');
      rethrow;
    }
  }
}

