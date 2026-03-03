/// PhonePe API Models
/// Models for PhonePe payment gateway integration

/// Payout request model
class PhonePePayoutRequest {
  final int expenseId;
  final String paymentMethod; // "VPA" or "BANK_ACCOUNT"
  final String? vpaAddress;
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;
  final String mobileNumber;
  final String? remarks;

  PhonePePayoutRequest({
    required this.expenseId,
    required this.paymentMethod,
    this.vpaAddress,
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    required this.mobileNumber,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'expense_id': expenseId,
      'payment_method': paymentMethod,
      'mobile_number': mobileNumber,
    };

    if (remarks != null && remarks!.isNotEmpty) {
      data['remarks'] = remarks;
    }

    if (paymentMethod == 'VPA') {
      data['vpa_address'] = vpaAddress;
    } else if (paymentMethod == 'BANK_ACCOUNT') {
      data['account_holder_name'] = accountHolderName;
      data['account_number'] = accountNumber;
      data['ifsc_code'] = ifscCode;
    }

    return data;
  }
}

/// Payout response model
class PhonePePayoutResponse {
  final bool success;
  final String message;
  final String paymentId;
  final String merchantTransactionId;
  final String? phonePeTransactionId;
  final String status;
  final double amount;
  final String createdAt;

  PhonePePayoutResponse({
    required this.success,
    required this.message,
    required this.paymentId,
    required this.merchantTransactionId,
    this.phonePeTransactionId,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory PhonePePayoutResponse.fromJson(Map<String, dynamic> json) {
    return PhonePePayoutResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      paymentId: json['payment_id'] ?? '',
      merchantTransactionId: json['merchant_transaction_id'] ?? '',
      phonePeTransactionId: json['phonepe_transaction_id'],
      status: json['status'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'payment_id': paymentId,
      'merchant_transaction_id': merchantTransactionId,
      'phonepe_transaction_id': phonePeTransactionId,
      'status': status,
      'amount': amount,
      'created_at': createdAt,
    };
  }
}

/// Payment status response model
class PhonePeStatusResponse {
  final bool success;
  final String paymentId;
  final String merchantTransactionId;
  final String? phonePeTransactionId;
  final String status;
  final String code;
  final String message;
  final double amount;
  final String? beneficiaryName;
  final String accountType;
  final String initiatedAt;
  final String? completedAt;

  PhonePeStatusResponse({
    required this.success,
    required this.paymentId,
    required this.merchantTransactionId,
    this.phonePeTransactionId,
    required this.status,
    required this.code,
    required this.message,
    required this.amount,
    this.beneficiaryName,
    required this.accountType,
    required this.initiatedAt,
    this.completedAt,
  });

  factory PhonePeStatusResponse.fromJson(Map<String, dynamic> json) {
    return PhonePeStatusResponse(
      success: json['success'] ?? false,
      paymentId: json['payment_id'] ?? '',
      merchantTransactionId: json['merchant_transaction_id'] ?? '',
      phonePeTransactionId: json['phonepe_transaction_id'],
      status: json['status'] ?? '',
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      beneficiaryName: json['beneficiary_name'],
      accountType: json['account_type'] ?? '',
      initiatedAt: json['initiated_at'] ?? '',
      completedAt: json['completed_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payment_id': paymentId,
      'merchant_transaction_id': merchantTransactionId,
      'phonepe_transaction_id': phonePeTransactionId,
      'status': status,
      'code': code,
      'message': message,
      'amount': amount,
      'beneficiary_name': beneficiaryName,
      'account_type': accountType,
      'initiated_at': initiatedAt,
      'completed_at': completedAt,
    };
  }

  bool get isSuccess => status == 'PAYMENT_SUCCESS';
  bool get isPending => status == 'PAYMENT_PENDING';
  bool get isFailed => status == 'PAYMENT_ERROR' || status == 'PAYMENT_DECLINED';
}

/// VPA validation response model
class PhonePeVPAValidationResponse {
  final bool success;
  final String vpaAddress;
  final bool isValid;
  final String? accountHolderName;
  final String message;

  PhonePeVPAValidationResponse({
    required this.success,
    required this.vpaAddress,
    required this.isValid,
    this.accountHolderName,
    required this.message,
  });

  factory PhonePeVPAValidationResponse.fromJson(Map<String, dynamic> json) {
    return PhonePeVPAValidationResponse(
      success: json['success'] ?? false,
      vpaAddress: json['vpa_address'] ?? '',
      isValid: json['is_valid'] ?? false,
      accountHolderName: json['account_holder_name'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'vpa_address': vpaAddress,
      'is_valid': isValid,
      'account_holder_name': accountHolderName,
      'message': message,
    };
  }
}

/// Payment history item model
class PhonePePaymentHistoryItem {
  final String paymentId;
  final int expenseId;
  final String requestId;
  final double amount;
  final String status;
  final String paymentMode;
  final String phonePeStatus;
  final String merchantTransactionId;
  final String? phonePeTransactionId;
  final String? beneficiaryName;
  final String accountType;
  final String initiatedAt;
  final String? completedAt;
  final String? errorMessage;

  PhonePePaymentHistoryItem({
    required this.paymentId,
    required this.expenseId,
    required this.requestId,
    required this.amount,
    required this.status,
    required this.paymentMode,
    required this.phonePeStatus,
    required this.merchantTransactionId,
    this.phonePeTransactionId,
    this.beneficiaryName,
    required this.accountType,
    required this.initiatedAt,
    this.completedAt,
    this.errorMessage,
  });

  factory PhonePePaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PhonePePaymentHistoryItem(
      paymentId: json['payment_id'] ?? '',
      expenseId: json['expense_id'] ?? 0,
      requestId: json['request_id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      paymentMode: json['payment_mode'] ?? '',
      phonePeStatus: json['phonepe_status'] ?? '',
      merchantTransactionId: json['merchant_transaction_id'] ?? '',
      phonePeTransactionId: json['phonepe_transaction_id'],
      beneficiaryName: json['beneficiary_name'],
      accountType: json['account_type'] ?? '',
      initiatedAt: json['initiated_at'] ?? '',
      completedAt: json['completed_at'],
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'expense_id': expenseId,
      'request_id': requestId,
      'amount': amount,
      'status': status,
      'payment_mode': paymentMode,
      'phonepe_status': phonePeStatus,
      'merchant_transaction_id': merchantTransactionId,
      'phonepe_transaction_id': phonePeTransactionId,
      'beneficiary_name': beneficiaryName,
      'account_type': accountType,
      'initiated_at': initiatedAt,
      'completed_at': completedAt,
      'error_message': errorMessage,
    };
  }
}

/// Payment history response model
class PhonePePaymentHistory {
  final bool success;
  final int totalCount;
  final List<PhonePePaymentHistoryItem> payments;

  PhonePePaymentHistory({
    required this.success,
    required this.totalCount,
    required this.payments,
  });

  factory PhonePePaymentHistory.fromJson(Map<String, dynamic> json) {
    return PhonePePaymentHistory(
      success: json['success'] ?? false,
      totalCount: json['total_count'] ?? 0,
      payments: (json['payments'] as List?)
              ?.map((e) => PhonePePaymentHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'total_count': totalCount,
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }
}
