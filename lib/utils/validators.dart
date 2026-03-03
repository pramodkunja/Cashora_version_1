import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'payment_constants.dart';

/// Validation result class for consistent validation responses
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  factory ValidationResult.valid() {
    return const ValidationResult(isValid: true, errors: []);
  }

  factory ValidationResult.invalid(List<String> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }

  factory ValidationResult.singleError(String error) {
    return ValidationResult(isValid: false, errors: [error]);
  }
}

/// File validator for QR codes and receipts
class FileValidator {
  /// Validate file for QR upload
  static ValidationResult validateQRUpload(XFile file) {
    final errors = <String>[];

    // 1. File type validation
    final fileName = file.name.toLowerCase();
    final hasValidExtension = PaymentConstants.allowedImageExtensions
        .any((ext) => fileName.endsWith('.$ext'));

    if (!hasValidExtension) {
      errors.add(
        'Please upload a valid image file (${PaymentConstants.allowedImageExtensions.join(", ").toUpperCase()})',
      );
    }

    // 2. File name validation
    if (file.name.isEmpty || file.name.length > PaymentConstants.maxFileNameLength) {
      errors.add('Invalid file name');
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Validate file for QR upload with size check (async)
  static Future<ValidationResult> validateQRUploadWithSize(XFile file) async {
    final errors = <String>[];

    // First, run basic validation
    final basicValidation = validateQRUpload(file);
    if (!basicValidation.isValid) {
      errors.addAll(basicValidation.errors);
    }

    // 2. File size validation (requires reading file)
    try {
      final fileSize = await file.length();
      if (fileSize > PaymentConstants.maxFileSizeBytes) {
        final maxSizeMB = PaymentConstants.maxFileSizeBytes / (1024 * 1024);
        errors.add('Image size must be less than ${maxSizeMB.toStringAsFixed(0)}MB');
      }
    } catch (e) {
      errors.add('Failed to read file size');
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Validate receipt file upload
  static Future<ValidationResult> validateReceiptUpload(XFile file) async {
    // Same validation as QR for now
    return validateQRUploadWithSize(file);
  }

  /// Check if URL is valid
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

/// QR data validator for payment information
class QRDataValidator {
  /// Validate QR data format
  static ValidationResult validateQRData(String qrData) {
    final errors = <String>[];

    // 1. Check if QR data is not empty
    if (qrData.trim().isEmpty) {
      errors.add('QR data is required');
      return ValidationResult.invalid(errors);
    }

    // 2. Check if it's a valid payment QR format
    final isUPI = qrData.startsWith('upi://') || qrData.contains('@');
    final hasBankAccount = RegExp(r'\d{9,18}').hasMatch(qrData);

    if (!isUPI && !hasBankAccount) {
      errors.add(
        'Invalid QR code format. Please upload a valid UPI payment QR code.',
      );
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Validate UPI ID format
  static bool isValidUPI(String upi) {
    // UPI format: username@bankname
    final upiRegex = RegExp(r'^[\w.-]+@[\w.-]+$');
    return upiRegex.hasMatch(upi);
  }

  /// Validate IFSC code format
  static bool isValidIFSC(String ifsc) {
    // IFSC format: 4 letters + 7 characters (11 total)
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    return ifscRegex.hasMatch(ifsc.toUpperCase());
  }

  /// Validate bank account number
  static bool isValidAccountNumber(String accountNumber) {
    // Account number: 9-18 digits
    final accountRegex = RegExp(r'^\d{9,18}$');
    return accountRegex.hasMatch(accountNumber);
  }

  /// Validate payee name
  static bool isValidPayeeName(String name) {
    return name.trim().isNotEmpty && name.length <= 100;
  }
}

/// Payment request validator
class PaymentValidator {
  /// Validate process QR request
  static ValidationResult validateProcessQRRequest({
    required int? expenseId,
    required String? qrImageUrl,
    required String? qrData,
  }) {
    final errors = <String>[];

    // 1. Expense ID validation
    if (expenseId == null || expenseId <= 0) {
      errors.add('Invalid expense ID');
    }

    // 2. QR image URL validation
    if (qrImageUrl == null || !FileValidator.isValidUrl(qrImageUrl)) {
      errors.add('Invalid QR image URL');
    }

    // 3. QR data validation
    if (qrData == null || qrData.trim().isEmpty) {
      errors.add('QR data is required');
    } else {
      final qrValidation = QRDataValidator.validateQRData(qrData);
      if (!qrValidation.isValid) {
        errors.addAll(qrValidation.errors);
      }
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Validate payout request
  static ValidationResult validatePayoutRequest({
    required int? expenseId,
    String? mode,
    String? narration,
    Map<String, dynamic>? notes,
  }) {
    final errors = <String>[];

    // 1. Expense ID validation
    if (expenseId == null || expenseId <= 0) {
      errors.add('Invalid expense ID');
    }

    // 2. Mode validation (optional, but if provided must be valid)
    if (mode != null && !PaymentConstants.validModes.contains(mode)) {
      errors.add(
        'Invalid payout mode. Must be one of: ${PaymentConstants.validModes.join(", ")}',
      );
    }

    // 3. Narration validation (optional, max 30 characters)
    if (narration != null && narration.length > PaymentConstants.maxNarrationLength) {
      errors.add(
        'Narration must be ${PaymentConstants.maxNarrationLength} characters or less',
      );
    }

    // 4. Notes validation (optional, max 15 key-value pairs)
    if (notes != null && notes.length > PaymentConstants.maxNotesCount) {
      errors.add('Maximum ${PaymentConstants.maxNotesCount} notes allowed');
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Validate expense for payout eligibility
  static ValidationResult validateExpenseForPayout({
    required String? status,
    required String? paymentType,
    required String? payeeName,
    String? payeeVpa,
    String? payeeAccountNumber,
    String? payeeIfsc,
  }) {
    final errors = <String>[];

    // 1. Validate expense status
    if (status != 'APPROVED') {
      errors.add('Only approved expenses can be paid');
    }

    // 2. Validate payment details exist
    if (paymentType == null || payeeName == null) {
      errors.add(
        'Payment details not found. Please ensure expense has a valid payment QR code.',
      );
    }

    // 3. Validate payment type
    if (paymentType != null &&
        !PaymentConstants.validPaymentTypes.contains(paymentType)) {
      errors.add('Invalid payment type');
    }

    // 4. Validate payee details based on type
    if (paymentType == PaymentConstants.typeUPI) {
      if (payeeVpa == null || !QRDataValidator.isValidUPI(payeeVpa)) {
        errors.add('Invalid UPI ID');
      }
    } else if (paymentType == PaymentConstants.typeBankAccount) {
      if (payeeAccountNumber == null || payeeIfsc == null) {
        errors.add('Bank account details are incomplete');
      } else {
        if (!QRDataValidator.isValidAccountNumber(payeeAccountNumber)) {
          errors.add('Invalid account number');
        }
        if (!QRDataValidator.isValidIFSC(payeeIfsc)) {
          errors.add('Invalid IFSC code');
        }
      }
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}

/// Response validator for API responses
class ResponseValidator {
  /// Validate process QR response
  static ValidationResult validateProcessQRResponse(Map<String, dynamic> response) {
    final errors = <String>[];

    // 1. Success flag validation
    if (!response.containsKey('success') || response['success'] is! bool) {
      errors.add('Invalid response format');
      return ValidationResult.invalid(errors);
    }

    // 2. If success, validate extracted data
    if (response['success'] == true) {
      final paymentType = response['payment_type'];
      if (paymentType == null ||
          !PaymentConstants.validPaymentTypes.contains(paymentType)) {
        errors.add('Invalid payment type');
      }

      final payeeName = response['payee_name'];
      if (payeeName == null || payeeName.toString().trim().isEmpty) {
        errors.add('Payee name is required');
      }

      if (paymentType == PaymentConstants.typeUPI) {
        final payeeVpa = response['payee_vpa'];
        if (payeeVpa == null || !QRDataValidator.isValidUPI(payeeVpa)) {
          errors.add('Invalid UPI ID');
        }
      } else if (paymentType == PaymentConstants.typeBankAccount) {
        final accountNumber = response['payee_account_number'];
        final ifsc = response['payee_ifsc'];
        if (accountNumber == null || ifsc == null) {
          errors.add('Bank account details are incomplete');
        }
      }

      final isValid = response['is_valid'];
      if (isValid != true) {
        errors.add('Extracted payment details are not valid');
      }
    } else {
      // If failed, validate error message
      if (!response.containsKey('message')) {
        errors.add('Error message is required');
      }
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Validate payout response
  static ValidationResult validatePayoutResponse(Map<String, dynamic> response) {
    final errors = <String>[];

    if (!response.containsKey('success') || response['success'] is! bool) {
      errors.add('Invalid response format');
      return ValidationResult.invalid(errors);
    }

    if (response['success'] == true) {
      // Validate required fields
      final requiredFields = [
        'payment_id',
        'merchant_transaction_id',
        'expense_id',
        'amount',
        'status',
      ];

      for (final field in requiredFields) {
        if (!response.containsKey(field) || response[field] == null) {
          errors.add('Missing required field: $field');
        }
      }

      // Validate amount
      final amount = response['amount'];
      if (amount != null && (amount is! num || amount <= 0)) {
        errors.add('Invalid amount');
      }

      // Validate status
      final status = response['status'];
      if (status != null && !PaymentConstants.validStatuses.contains(status)) {
        errors.add('Invalid payment status');
      }
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Validate payment status response
  static ValidationResult validatePaymentStatusResponse(
    Map<String, dynamic> response,
  ) {
    final errors = <String>[];

    // Required fields
    final requiredFields = ['payment_id', 'expense_id', 'status', 'amount'];
    for (final field in requiredFields) {
      if (!response.containsKey(field) || response[field] == null) {
        errors.add('Missing required field: $field');
      }
    }

    // Status validation
    final status = response['status'];
    if (status != null && !PaymentConstants.validStatuses.contains(status)) {
      errors.add('Invalid payment status');
    }

    // If success, UTR should be present
    if (status == PaymentConstants.statusSuccess) {
      if (!response.containsKey('utr') || response['utr'] == null) {
        errors.add('UTR is required for successful payments');
      }
    }

    // If failed, failure reason should be present
    if (status == PaymentConstants.statusFailed) {
      if (!response.containsKey('failure_reason') ||
          response['failure_reason'] == null) {
        errors.add('Failure reason is required for failed payments');
      }
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}
