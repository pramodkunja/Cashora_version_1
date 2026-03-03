import 'dart:async';
import 'package:get/get.dart';
import '../../data/repositories/payment_repository.dart';
import '../../utils/payment_constants.dart';

/// Service to handle payment status polling
class PaymentStatusService extends GetxService {
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();
  
  // Active polling timers
  final Map<int, Timer> _activePolls = {};
  
  // Polling callbacks
  final Map<int, Function(Map<String, dynamic>)> _statusCallbacks = {};
  final Map<int, Function(String)> _errorCallbacks = {};
  
  /// Start polling payment status for an expense
  /// 
  /// [expenseId] - ID of the expense to poll
  /// [onStatusUpdate] - Callback when status updates
  /// [onError] - Callback when error occurs
  /// [onComplete] - Callback when polling completes (success/failure)
  void startPolling({
    required int expenseId,
    required Function(Map<String, dynamic>) onStatusUpdate,
    Function(String)? onError,
    Function(Map<String, dynamic>)? onComplete,
  }) {
    // Stop existing poll if any
    stopPolling(expenseId);
    
    print('🔄 Starting payment status polling for expense $expenseId');
    
    int pollCount = 0;
    
    // Store callbacks
    _statusCallbacks[expenseId] = onStatusUpdate;
    if (onError != null) {
      _errorCallbacks[expenseId] = onError;
    }
    
    // Create polling timer
    _activePolls[expenseId] = Timer.periodic(
      Duration(seconds: PaymentConstants.pollIntervalSeconds),
      (timer) async {
        pollCount++;
        
        try {
          // Fetch payment status
          final status = await _paymentRepository.getPaymentStatus(expenseId);
          
          // Call status update callback
          onStatusUpdate(status);
          
          final currentStatus = status['status'] as String?;
          
          // Check if status is terminal
          if (currentStatus != null &&
              PaymentConstants.isTerminalStatus(currentStatus)) {
            print('✅ Payment status polling completed: $currentStatus');
            
            // Stop polling
            stopPolling(expenseId);
            
            // Call completion callback
            onComplete?.call(status);
            
            return;
          }
          
          // Check if max polls reached
          if (pollCount >= PaymentConstants.maxPollAttempts) {
            print('⚠️ Max polling attempts reached for expense $expenseId');
            
            // Stop polling
            stopPolling(expenseId);
            
            // Call error callback
            onError?.call(
              'Payment is taking longer than expected. Please check status later.',
            );
            
            return;
          }
          
          print('🔄 Poll #$pollCount - Status: $currentStatus');
          
        } catch (e) {
          print('❌ Error polling payment status: $e');
          
          // Don't stop polling on error, just notify
          onError?.call('Failed to fetch payment status');
        }
      },
    );
  }
  
  /// Stop polling for an expense
  void stopPolling(int expenseId) {
    if (_activePolls.containsKey(expenseId)) {
      _activePolls[expenseId]?.cancel();
      _activePolls.remove(expenseId);
      _statusCallbacks.remove(expenseId);
      _errorCallbacks.remove(expenseId);
      
      print('🛑 Stopped payment status polling for expense $expenseId');
    }
  }
  
  /// Stop all active polls
  void stopAllPolling() {
    for (final expenseId in _activePolls.keys.toList()) {
      stopPolling(expenseId);
    }
    print('🛑 Stopped all payment status polling');
  }
  
  /// Check if polling is active for an expense
  bool isPolling(int expenseId) {
    return _activePolls.containsKey(expenseId);
  }
  
  /// Get number of active polls
  int get activePollCount => _activePolls.length;
  
  @override
  void onClose() {
    stopAllPolling();
    super.onClose();
  }
}
