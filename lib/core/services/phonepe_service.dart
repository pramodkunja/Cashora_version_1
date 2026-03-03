import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../services/network_service.dart';
import '../services/storage_service.dart';

/// Service to handle PhonePe payment gateway integration
/// Implements automated payout system with status polling
class PhonePeService extends GetxService {
  final NetworkService _networkService;
  final StorageService _storageService;

  PhonePeService(this._networkService, this._storageService);

  /// Initiate PhonePe payout
  /// 
  /// [expenseId] - ID of the expense to pay
  /// [paymentMethod] - "VPA" or "BANK_ACCOUNT"
  /// [vpaAddress] - UPI ID (required if paymentMethod is VPA)
  /// [accountHolderName] - Account holder name (required if BANK_ACCOUNT)
  /// [accountNumber] - Bank account number (required if BANK_ACCOUNT)
  /// [ifscCode] - IFSC code (required if BANK_ACCOUNT)
  /// [mobileNumber] - Beneficiary mobile number (required)
  /// [remarks] - Payment remarks (optional)
  /// 
  /// Returns payment details including payment_id and transaction IDs
  Future<Map<String, dynamic>> initiatePayoutAPI({
    required int expenseId,
    required String paymentMethod,
    String? vpaAddress,
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    required String mobileNumber,
    String? remarks,
  }) async {
    try {
      final token = await _storageService.read('auth_token');

      print('🚀 PhonePe: Initiating payout');
      print('   Expense ID: $expenseId');
      print('   Payment Method: $paymentMethod');
      print('   Mobile: $mobileNumber');

      final requestData = {
        'expense_id': expenseId,
        'payment_method': paymentMethod,
        'mobile_number': mobileNumber,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      // Add method-specific fields
      if (paymentMethod == 'VPA') {
        if (vpaAddress == null || vpaAddress.isEmpty) {
          throw 'VPA address is required for UPI payment';
        }
        requestData['vpa_address'] = vpaAddress;
        print('   VPA: $vpaAddress');
      } else if (paymentMethod == 'BANK_ACCOUNT') {
        if (accountHolderName == null || accountHolderName.isEmpty) {
          throw 'Account holder name is required';
        }
        if (accountNumber == null || accountNumber.isEmpty) {
          throw 'Account number is required';
        }
        if (ifscCode == null || ifscCode.isEmpty) {
          throw 'IFSC code is required';
        }
        requestData['account_holder_name'] = accountHolderName;
        requestData['account_number'] = accountNumber;
        requestData['ifsc_code'] = ifscCode;
        print('   Account: $accountNumber');
        print('   IFSC: $ifscCode');
      }

      final response = await _networkService.post(
        '/api/v1/phonepe/payout/initiate',
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ PhonePe: Payout initiated successfully');
      print('   Payment ID: ${response.data['payment_id']}');
      print('   Merchant Txn ID: ${response.data['merchant_transaction_id']}');

      return response.data;
    } catch (e) {
      print('❌ PhonePe: Payout initiation failed: $e');
      rethrow;
    }
  }

  /// Check payment status
  /// 
  /// [paymentId] - Payment ID (optional)
  /// [merchantTransactionId] - Merchant transaction ID (optional)
  /// 
  /// At least one ID must be provided
  Future<Map<String, dynamic>> checkPaymentStatusAPI({
    String? paymentId,
    String? merchantTransactionId,
  }) async {
    try {
      if (paymentId == null && merchantTransactionId == null) {
        throw 'Either payment_id or merchant_transaction_id is required';
      }

      final token = await _storageService.read('auth_token');

      final requestData = <String, dynamic>{};
      if (paymentId != null) {
        requestData['payment_id'] = paymentId;
      }
      if (merchantTransactionId != null) {
        requestData['merchant_transaction_id'] = merchantTransactionId;
      }

      final response = await _networkService.post(
        '/api/v1/phonepe/payout/status',
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } catch (e) {
      print('❌ PhonePe: Status check failed: $e');
      rethrow;
    }
  }

  /// Validate VPA (UPI ID)
  /// 
  /// [vpaAddress] - UPI ID to validate
  /// 
  /// Returns validation result with account holder name if valid
  Future<Map<String, dynamic>> validateVPAAPI(String vpaAddress) async {
    try {
      final token = await _storageService.read('auth_token');

      print('🔍 PhonePe: Validating VPA: $vpaAddress');

      final response = await _networkService.post(
        '/api/v1/phonepe/validate-vpa',
        data: {'vpa_address': vpaAddress},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final isValid = response.data['is_valid'] ?? false;
      if (isValid) {
        print('✅ PhonePe: VPA is valid');
        print('   Account Holder: ${response.data['account_holder_name']}');
      } else {
        print('❌ PhonePe: VPA is invalid');
      }

      return response.data;
    } catch (e) {
      print('❌ PhonePe: VPA validation failed: $e');
      rethrow;
    }
  }

  /// Get payment history
  /// 
  /// [expenseId] - Filter by expense ID (optional)
  /// [status] - Filter by status: success, failure, processing, pending (optional)
  /// [limit] - Number of records to fetch (default: 50, max: 100)
  Future<Map<String, dynamic>> getPaymentHistoryAPI({
    int? expenseId,
    String? status,
    int limit = 50,
  }) async {
    try {
      final token = await _storageService.read('auth_token');

      final queryParams = <String, dynamic>{};
      if (expenseId != null) {
        queryParams['expense_id'] = expenseId;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      queryParams['limit'] = limit.clamp(1, 100);

      final response = await _networkService.get(
        '/api/v1/phonepe/payments/history',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ PhonePe: Fetched ${response.data['total_count']} payment records');

      return response.data;
    } catch (e) {
      print('❌ PhonePe: Payment history fetch failed: $e');
      rethrow;
    }
  }

  /// Poll payment status until completion or timeout
  /// 
  /// [paymentId] - Payment ID to poll
  /// [maxAttempts] - Maximum polling attempts (default: 20)
  /// [intervalSeconds] - Seconds between polls (default: 5)
  /// 
  /// Returns final status response or throws timeout error
  Future<Map<String, dynamic>> pollPaymentStatus({
    required String paymentId,
    int maxAttempts = 20,
    int intervalSeconds = 5,
  }) async {
    print('🔄 PhonePe: Starting status polling');
    print('   Payment ID: $paymentId');
    print('   Max attempts: $maxAttempts');
    print('   Interval: ${intervalSeconds}s');

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      print('🔄 Polling attempt $attempt/$maxAttempts...');

      try {
        final statusResponse = await checkPaymentStatusAPI(paymentId: paymentId);
        final status = statusResponse['status'];

        print('   Status: $status');

        // Check if payment is complete
        if (status == 'PAYMENT_SUCCESS') {
          print('✅ PhonePe: Payment completed successfully');
          return statusResponse;
        }

        if (status == 'PAYMENT_ERROR' || status == 'PAYMENT_DECLINED') {
          print('❌ PhonePe: Payment failed');
          return statusResponse;
        }

        // Still pending, wait before next poll
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: intervalSeconds));
        }
      } catch (e) {
        print('⚠️ PhonePe: Polling attempt $attempt failed: $e');
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: intervalSeconds));
        } else {
          rethrow;
        }
      }
    }

    // Timeout
    print('⏱️ PhonePe: Payment status polling timeout');
    throw 'Payment status check timeout after ${maxAttempts * intervalSeconds} seconds';
  }
}
