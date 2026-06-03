import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/network_service.dart';
import '../../core/services/storage_service.dart';

class PaymentRepository {
  final NetworkService _networkService;

  PaymentRepository(this._networkService);

  /// Whether the dedicated `/payments/*` router is available on the backend.
  /// Backend ships these routes today — flag is kept so a runtime 404 can
  /// still flip it off and gate UI, but it defaults to "available".
  static final RxBool paymentsAvailable = true.obs;

  /// Generic 404 detector for the payments router. When the router is
  /// missing, we flip `paymentsAvailable` off so UI buttons disable
  /// themselves on the next rebuild.
  bool _isPaymentsRouterMissing(Object e) {
    if (e is DioException && e.response?.statusCode == 404) {
      paymentsAvailable.value = false;
      return true;
    }
    return false;
  }

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
      paymentsAvailable.value = true;
    } catch (e) {
      if (_isPaymentsRouterMissing(e)) return;
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final response = await _networkService.get('/payments/history');
      paymentsAvailable.value = true;
      if (response.data is List) {
        return (response.data as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      _isPaymentsRouterMissing(e);
      return [];
    }
  }

  static final RegExp _vpaRegex =
      RegExp(r'^[a-zA-Z0-9._-]{2,}@[a-zA-Z]{2,}$');

  Future<Map<String, dynamic>> initiatePayment({
    required String requestId,
    required String payeeVpa,
    required double amount,
    String? payeeName,
    String? transactionNote,
  }) async {
    final vpa = payeeVpa.trim();
    if (!_vpaRegex.hasMatch(vpa)) {
      throw ArgumentError('Invalid UPI ID format: "$payeeVpa"');
    }
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    try {
      // Fetch token explicitly as requested
      final storage = Get.find<StorageService>();
      final token = await storage.read('auth_token');

      final response = await _networkService.post(
        '/payments/initiate',
        data: {
          'request_id': requestId,
          'payee_vpa': vpa,
          'amount': amount,
          'payee_name': payeeName,
          'transaction_note': transactionNote,
        },
        // Explicitly set header as per guide to ensure it's passed correctly
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      paymentsAvailable.value = true;
      return response.data; // Expecting { "payment_id": "..." }
    } catch (e) {
      if (_isPaymentsRouterMissing(e)) {
        return const {
          'unavailable': true,
          'message': 'Payment processing coming soon',
        };
      }
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
      paymentsAvailable.value = true;
      return response.data;
    } catch (e) {
      if (_isPaymentsRouterMissing(e)) {
        return const {
          'unavailable': true,
          'message': 'Payment processing coming soon',
        };
      }
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
      paymentsAvailable.value = true;

      if (response.data is Map && response.data['payments'] is List) {
        return List<Map<String, dynamic>>.from(response.data['payments']);
      }
      return [];
    } catch (e) {
      _isPaymentsRouterMissing(e);
      if (kDebugMode) debugPrint("Error fetching completed payments: $e");
      return [];
    }
  }
  Future<void> markAsPaid(
    dynamic id, {
    required String method,
    String? transactionRef,
    String? paymentNote,
  }) async {
    try {
      final expenseId = id is int ? id : int.parse(id.toString());
      final storage = Get.find<StorageService>();
      final token = await storage.read('auth_token');

      final payload = <String, dynamic>{
        'payment_method': method,
      };
      if (transactionRef != null && transactionRef.trim().isNotEmpty) {
        payload['transaction_reference'] = transactionRef.trim();
      }
      if (paymentNote != null && paymentNote.trim().isNotEmpty) {
        payload['payment_note'] = paymentNote.trim();
      }

      await _networkService.post(
        '/accountant/expenses/$expenseId/mark-as-paid',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      if (kDebugMode) debugPrint("Error marking as paid: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPaymentMethods() async {
    final response = await _networkService.get('/accountant/payment-methods');
    if (response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    }
    return [];
  }

  Future<Map<String, dynamic>> getPaymentStatus(int expenseId) async {
    try {
      final storage = Get.find<StorageService>();
      final token = await storage.read('auth_token');

      final response = await _networkService.get(
        '/accountant/expenses/$expenseId/payment-status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      return {'status': 'unknown'};
    } on DioException catch (e) {
      // TODO(backend): /accountant/expenses/{id}/payment-status not yet
      // deployed — surface "Status unknown" instead of an error so the UI
      // doesn't display a stack trace.
      if (e.response?.statusCode == 404) {
        return {'status': 'unknown', 'label': 'Status unknown'};
      }
      if (kDebugMode) debugPrint("Error fetching payment status: $e");
      return {'status': 'error', 'message': e.toString()};
    } catch (e) {
      if (kDebugMode) debugPrint("Error fetching payment status: $e");
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
