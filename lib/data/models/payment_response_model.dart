import 'user_model.dart';

class PaymentResponse {
  final int total;
  final int page;
  final int size;
  final List<Payment> payments;

  PaymentResponse({
    required this.total,
    required this.page,
    required this.size,
    required this.payments,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    // API returns 'items' (paginated response), fall back to 'payments' for
    // any legacy endpoints.
    final rawList =
        (json['items'] as List?) ?? (json['payments'] as List?) ?? [];
    return PaymentResponse(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 25,
      payments: rawList
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'size': size,
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }
}

class Payment {
  final int? id;
  final String? paymentId;
  final int? expenseId;
  final String? requestId;
  final String? expenseStatus;
  final double amountPaid;
  final String? status;
  final String? transactionId;
  final String? processedAt;
  final String? createdAt;
  final Map<String, dynamic>? metaData;
  final Expense? expense;

  Payment({
    this.id,
    this.paymentId,
    this.expenseId,
    this.requestId,
    this.expenseStatus,
    required this.amountPaid,
    this.status,
    this.transactionId,
    this.processedAt,
    this.createdAt,
    this.metaData,
    this.expense,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int?,
      paymentId: json['payment_id'] as String?,
      expenseId: json['expense_id'] as int?,
      requestId: json['request_id'] as String?,
      expenseStatus: json['expense_status'] as String?,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String?,
      transactionId: json['transaction_id'] as String?,
      processedAt: json['processed_at'] as String?,
      createdAt: json['created_at'] as String?,
      metaData: json['meta_data'] as Map<String, dynamic>?,
      expense: json['expense'] != null
          ? Expense.fromJson(json['expense'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_id': paymentId,
      'expense_id': expenseId,
      'request_id': requestId,
      'expense_status': expenseStatus,
      'amount_paid': amountPaid,
      'status': status,
      'transaction_id': transactionId,
      'processed_at': processedAt,
      'created_at': createdAt,
      'meta_data': metaData,
      'expense': expense?.toJson(),
    };
  }
}

class Expense {
  final int? id;
  final String? description;
  final String? category;
  final String? expenseStatus;
  final String? paymentStatus;
  final String? requestType;
  final String? requestId;
  final String? purpose;
  final double amount;
  final String? receiptUrl;
  final List<String> billUrls;
  final String? qrUrl;
  final String? rejectionReason;
  final User? requestor;
  final User? approver;
  final QrData? qr;
  final String? createdAt;
  final String? updatedAt;

  Expense({
    this.id,
    this.description,
    this.category,
    this.expenseStatus,
    this.paymentStatus,
    this.requestType,
    this.requestId,
    this.purpose,
    required this.amount,
    this.receiptUrl,
    required this.billUrls,
    this.qrUrl,
    this.rejectionReason,
    this.requestor,
    this.approver,
    this.qr,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      expenseStatus: json['status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      requestType: json['request_type'] as String?,
      requestId: json['request_id'] as String?,
      purpose: json['purpose'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      receiptUrl: json['receipt_url'] as String?,
      billUrls:
          (json['bill_urls'] as List?)?.map((e) => e as String).toList() ?? [],
      qrUrl: json['qr_url'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      requestor: json['requestor'] != null
          ? User.fromJson(json['requestor'] as Map<String, dynamic>)
          : null,
      approver: json['approver'] != null
          ? User.fromJson(json['approver'] as Map<String, dynamic>)
          : null,
      qr: json['qr'] != null
          ? QrData.fromJson(json['qr'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'status': expenseStatus,
      'payment_status': paymentStatus,
      'request_type': requestType,
      'request_id': requestId,
      'purpose': purpose,
      'amount': amount,
      'receipt_url': receiptUrl,
      'bill_urls': billUrls,
      'qr_url': qrUrl,
      'rejection_reason': rejectionReason,
      'requestor': requestor?.toJson(),
      'approver': approver?.toJson(),
      'qr': qr?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class QrData {
  final String? type;
  final String? payload;
  final String? svgBase64;

  QrData({this.type, this.payload, this.svgBase64});

  factory QrData.fromJson(Map<String, dynamic> json) {
    return QrData(
      type: json['type'] as String?,
      payload: json['payload'] as String?,
      svgBase64: json['svg_base64'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'payload': payload, 'svg_base64': svgBase64};
  }
}
