import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../core/services/network_service.dart';
import '../../core/services/storage_service.dart';

class PaymentRepository {
  final NetworkService _networkService;

  PaymentRepository(this._networkService);

  Future<void> recordPayment({
    required double amount,
    required String method, // 'UPI', 'CASH', 'CUSTOM'
    String? transactionId,
    String? note,
  }) async {
    try {
      await _networkService.post(
        '/payments/record',
        data: {
          'amount': amount,
          'payment_method': method,
          'transaction_id': transactionId,
          'note': note,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final response = await _networkService.get('/payments/history');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      // Return empty list on error for now, or rethrow based on UI needs
      return [];
    }
  }

  Future<Map<String, dynamic>> initiatePayment({
    required String requestId,
    required String payeeVpa,
    required double amount,
    String? payeeName,
    String? transactionNote,
  }) async {
    try {
      // Fetch token explicitly as requested
      final storage = Get.find<StorageService>();
      final token = await storage.read('auth_token');

      final response = await _networkService.post(
        '/payments/initiate',
        data: {
          'request_id': requestId,
          'payee_vpa': payeeVpa,
          'amount': amount,
          'payee_name': payeeName,
          'transaction_note': transactionNote,
        },
        // Explicitly set header as per guide to ensure it's passed correctly
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data; // Expecting { "payment_id": "..." }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String paymentId,
    required String status,
    String? upiTxnId,
    String? errorMessage,
  }) async {
    try {
      // Fetch token explicitly as requested
      final storage = Get.find<StorageService>();
      final token = await storage.read('auth_token');

      final response = await _networkService.post(
        '/payments/confirm',
        data: {
          'payment_id': paymentId,
          'status': status,
          'upi_txn_id': upiTxnId,
          'error_message': errorMessage,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCompletedPayments() async {
    try {
      final storage = Get.find<StorageService>();
      final token = await storage.read('auth_token');

      final response = await _networkService.get(
        '/payments/completed',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map && response.data['payments'] is List) {
        return List<Map<String, dynamic>>.from(response.data['payments']);
      }
      return [];
    } catch (e) {
      print("Error fetching completed payments: $e");
      return [];
    }
  }
  Future<void> markAsPaid(dynamic id) async {
    try {
      final expenseId = id is int ? id : int.parse(id.toString());
      final storage = Get.find<StorageService>();
      final token = await storage.read('auth_token');

      await _networkService.post(
        '/accountant/expenses/$expenseId/mark-as-paid',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      print("Error marking as paid: $e");
      rethrow;
    }
  }

}
