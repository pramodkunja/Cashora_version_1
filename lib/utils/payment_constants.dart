/// Payment-related constants for QR-based payment validation system
class PaymentConstants {
  // Payment Statuses
  static const String statusPending = 'PENDING';
  static const String statusProcessing = 'PROCESSING';
  static const String statusSuccess = 'SUCCESS';
  static const String statusFailed = 'FAILED';
  static const String statusReversed = 'REVERSED';
  static const String statusCancelled = 'CANCELLED';

  static const List<String> validStatuses = [
    statusPending,
    statusProcessing,
    statusSuccess,
    statusFailed,
    statusReversed,
    statusCancelled,
  ];

  // Payment Modes
  static const String modeIMPS = 'IMPS';
  static const String modeNEFT = 'NEFT';
  static const String modeRTGS = 'RTGS';
  static const String modeUPI = 'UPI';

  static const List<String> validModes = [
    modeIMPS,
    modeNEFT,
    modeRTGS,
    modeUPI,
  ];

  // Payment Types
  static const String typeUPI = 'upi';
  static const String typeBankAccount = 'bank_account';

  static const List<String> validPaymentTypes = [
    typeUPI,
    typeBankAccount,
  ];

  // File Upload Validation
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
  ];
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const int maxFileNameLength = 255;

  // Polling Configuration
  static const int pollIntervalSeconds = 5;
  static const int maxPollAttempts = 60; // 5 minutes max (60 * 5 seconds)

  // Narration Limits
  static const int maxNarrationLength = 30;
  static const int maxNotesCount = 15;

  // Error Codes
  static const String errorInvalidQRFormat = 'INVALID_QR_FORMAT';
  static const String errorQRScanFailed = 'QR_SCAN_FAILED';
  static const String errorNoPaymentDetails = 'NO_PAYMENT_DETAILS';
  static const String errorPaymentDetailsNotFound = 'PAYMENT_DETAILS_NOT_FOUND';
  static const String errorExpenseNotApproved = 'EXPENSE_NOT_APPROVED';
  static const String errorInsufficientBalance = 'INSUFFICIENT_BALANCE';
  static const String errorInvalidBeneficiary = 'INVALID_BENEFICIARY';
  static const String errorUnauthorized = 'UNAUTHORIZED';
  static const String errorInvalidRole = 'INVALID_ROLE';
  static const String errorInvalidVpa = 'INVALID_VPA';
  static const String errorPhonePeError = 'PHONEPE_ERROR';
  static const String errorPaymentDeclined = 'PAYMENT_DECLINED';

  // Error Messages
  static const Map<String, String> errorMessages = {
    errorInvalidQRFormat: 'Invalid QR code format. Please upload a valid UPI payment QR code.',
    errorQRScanFailed: 'Failed to scan QR code. Please ensure the image is clear.',
    errorNoPaymentDetails: 'Could not extract payment details from QR code.',
    errorPaymentDetailsNotFound: 'Payment details not found for this expense.',
    errorExpenseNotApproved: 'Only approved expenses can be paid.',
    errorInsufficientBalance: 'Insufficient balance in PhonePe merchant account.',
    errorInvalidBeneficiary: 'Invalid beneficiary details.',
    errorUnauthorized: 'You do not have permission to perform this action.',
    errorInvalidRole: 'Only accountants can initiate payouts.',
    errorInvalidVpa: 'Invalid UPI ID. Please verify and try again.',
    errorPhonePeError: 'PhonePe service error. Please try again later.',
    errorPaymentDeclined: 'Payment declined by bank or UPI provider.',
  };

  /// Get user-friendly error message for error code
  static String getErrorMessage(String errorCode, [String? customMessage]) {
    return errorMessages[errorCode] ?? customMessage ?? 'An error occurred';
  }

  /// Check if status is terminal (no more updates expected)
  static bool isTerminalStatus(String status) {
    return [statusSuccess, statusFailed, statusReversed, statusCancelled]
        .contains(status);
  }

  /// Check if status indicates success
  static bool isSuccessStatus(String status) {
    return status == statusSuccess;
  }

  /// Check if status indicates failure
  static bool isFailureStatus(String status) {
    return [statusFailed, statusReversed, statusCancelled].contains(status);
  }

  /// Check if status indicates processing
  static bool isProcessingStatus(String status) {
    return [statusPending, statusProcessing].contains(status);
  }
}

/// Payment status display configuration
class PaymentStatusConfig {
  final String icon;
  final String color;
  final String text;
  final String description;
  final bool showSpinner;
  final bool showRetry;

  const PaymentStatusConfig({
    required this.icon,
    required this.color,
    required this.text,
    required this.description,
    this.showSpinner = false,
    this.showRetry = false,
  });

  static PaymentStatusConfig getConfig(String status) {
    switch (status) {
      case PaymentConstants.statusPending:
        return const PaymentStatusConfig(
          icon: '⏳',
          color: 'gray',
          text: 'Pending',
          description: 'Payment not yet initiated',
        );
      case PaymentConstants.statusProcessing:
        return const PaymentStatusConfig(
          icon: '🔄',
          color: 'blue',
          text: 'Processing',
          description: 'Payment is being processed by PhonePe',
          showSpinner: true,
        );
      case PaymentConstants.statusSuccess:
        return const PaymentStatusConfig(
          icon: '✅',
          color: 'green',
          text: 'Success',
          description: 'Payment completed successfully',
        );
      case PaymentConstants.statusFailed:
        return const PaymentStatusConfig(
          icon: '❌',
          color: 'red',
          text: 'Failed',
          description: 'Payment failed',
          showRetry: true,
        );
      case PaymentConstants.statusReversed:
        return const PaymentStatusConfig(
          icon: '↩️',
          color: 'orange',
          text: 'Reversed',
          description: 'Payment was reversed',
        );
      case PaymentConstants.statusCancelled:
        return const PaymentStatusConfig(
          icon: '🚫',
          color: 'gray',
          text: 'Cancelled',
          description: 'Payment was cancelled',
        );
      default:
        return const PaymentStatusConfig(
          icon: '⏳',
          color: 'gray',
          text: 'Pending',
          description: 'Payment not yet initiated',
        );
    }
  }
}
