import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/network_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/config/app_config.dart';
import '../../core/services/web_form_upload.dart';

class RequestRepository {
  final NetworkService _networkService;

  RequestRepository(this._networkService);

  Future<List<String>> getCategories() async {
    final response = await _networkService.get('/requestor/categories');
    if (response.data is List) {
      return List<String>.from(response.data);
    }
    return [];
  }

  /// GET /requestor/dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _networkService.get('/requestor/dashboard');
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Invalid dashboard response');
  }

  Future<Map<String, dynamic>> submitRequest({
    required String requestType,
    required double amount,
    required String purpose,
    required String description,
    required String category,
    String? paymentNote,
    XFile? qrFile,
    XFile? receiptFile,
    List<XFile>? billFiles,
  }) async {
    // Correct API field names (from backend spec):
    //   payment_qr_file  → QR code image
    //   receipt_file     → receipt / bill image
    //   payment_note     → text note for accountant

    // ── WEB ─────────────────────────────────────────────────────────────────
    if (kIsWeb) {
      final token =
          await Get.find<StorageService>().read('auth_token') ?? '';

      final List<Map<String, dynamic>> fileList = [];

      Future<void> collectFile(String key, XFile f) async {
        final bytes = await f.readAsBytes();
        fileList.add({'key': key, 'bytes': bytes, 'filename': f.name});
      }

      if (qrFile != null) await collectFile('payment_qr_file', qrFile);
      if (receiptFile != null) await collectFile('receipt_file', receiptFile);
      // Bill attachments also go as receipt_file (multiple allowed)
      if (billFiles != null) {
        for (final f in billFiles) await collectFile('receipt_file', f);
      }

      final Map<String, String> fields = {
        'request_type': requestType,
        'amount': amount.toString(),
        'purpose': purpose,
        'description': description,
        'category': category,
      };
      if (paymentNote != null && paymentNote.isNotEmpty) {
        fields['payment_note'] = paymentNote;
      }

      return await webMultipartPost(
        url: '${AppConfig.apiBaseUrl}/requestor/submit',
        token: token,
        fields: fields,
        files: fileList,
      );
    }

    // ── NATIVE (iOS / Android / Desktop) ────────────────────────────────────
    {
      final Map<String, dynamic> formFields = {
        'request_type': requestType,
        'amount': amount.toString(),
        'purpose': purpose,
        'description': description,
        'category': category,
      };
      if (paymentNote != null && paymentNote.isNotEmpty) {
        formFields['payment_note'] = paymentNote;
      }

      final FormData formData = FormData.fromMap(formFields);

      Future<void> addFile(String key, XFile file) async {
        formData.files.add(
          MapEntry(
            key,
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }

      if (qrFile != null) await addFile('payment_qr_file', qrFile);
      if (receiptFile != null) await addFile('receipt_file', receiptFile);
      if (billFiles != null && billFiles.isNotEmpty) {
        for (final f in billFiles) await addFile('receipt_file', f);
      }

      final response = await _networkService.post(
        '/requestor/submit',
        data: formData,
      );
      return response.data;
    }
  }



  /// GET /requestor/requests
  ///
  /// [status] — one of: All, Pending, Clarification, Approved, Rejected, Unpaid
  /// [search] — optional free-text search
  Future<List<Map<String, dynamic>>> getMyRequests({
    String? status,
    String? search,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _networkService.get(
      '/requestor/requests',
      queryParameters: queryParams,
    );

    if (response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    }
    return [];
  }

  /// Process payment QR code and extract payment details
  /// 
  /// [expenseId] - ID of the expense
  /// [qrImageUrl] - Cloudinary URL of the uploaded QR image
  /// [qrData] - Raw QR code data extracted from the image
  /// 
  /// Returns extracted payment details including payee name, VPA/account, etc.
  Future<Map<String, dynamic>> processPaymentQR({
    required int expenseId,
    required String qrImageUrl,
    required String qrData,
  }) async {
    try {
      final response = await _networkService.post(
        '/expenses/process-payment-qr',
        data: {
          'expense_id': expenseId,
          'qr_image_url': qrImageUrl,
          'qr_data': qrData,
        },
      );

      return response.data;
    } catch (e) {
      if (kDebugMode) debugPrint('Error processing payment QR: $e');
      rethrow;
    }
  }

  Future<void> submitClarification(dynamic id, String remarks) async {
    try {
      await _networkService.post(
        '/requestor/respond-clarification/$id',
        data: {'response_text': remarks},
      );
    } catch (e) {
      rethrow;
    }
  }
}
