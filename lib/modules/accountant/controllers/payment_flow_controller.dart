import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/payment_repository.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/services/storage_service.dart';
import 'accountant_payments_controller.dart';

class PaymentFlowController extends GetxController {
  // Dependencies
  late final PaymentRepository _paymentRepository;

  // State
  final RxBool isQrDetected = false.obs;
  final RxString selectedPaymentMethod = 'VPA'.obs; // VPA or BANK_ACCOUNT
  final RxBool isLoading = false.obs;

  // Scanned Details (keeping for QR code compatibility)
  final RxMap<String, String> scannedDetails = <String, String>{}.obs;

  // View State
  final RxString currentImageUrl = ''.obs;
  final RxString currentTitle = ''.obs;
  final RxBool isQrMode = false.obs;
  final RxBool isScanning = false.obs;

  // Current Request Data
  final RxMap<String, dynamic> currentRequest = <String, dynamic>{}.obs;

  // Payment State
  String? _currentPayoutId;
  final RxDouble requestedAmount = 150.00.obs;
  final RxDouble finalAmount = 150.00.obs;
  final adjustmentController = TextEditingController();

  // Payment Form Fields
  final vpaController = TextEditingController();
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final remarksController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // Initialize dependencies
    if (!Get.isRegistered<PaymentRepository>()) {
      Get.put(PaymentRepository(Get.find<NetworkService>()));
    }
    _paymentRepository = Get.find<PaymentRepository>();

    // Parse passed Request Data
    if (Get.arguments != null && Get.arguments is Map) {
      print("PaymentFlowController Args: ${Get.arguments}");
      if (Get.arguments['request'] != null) {
        final req = Get.arguments['request'];
        try {
          final amt = double.tryParse(req['amount']?.toString() ?? '0') ?? 0.0;
          requestedAmount.value = amt;
          finalAmount.value = amt;
          currentRequest.value = req;
          print("PaymentFlowController initialized with request: ${req['id']}");
        } catch (e) {
          print("Error parsing request args: $e");
        }
      }

      // Init View Data
      currentImageUrl.value = Get.arguments['url'] ?? '';
      currentTitle.value = Get.arguments['title'] ?? 'Details';
      isQrMode.value = Get.arguments['isQr'] ?? false;

      print("Init QR Mode: ${isQrMode.value}, URL: ${currentImageUrl.value}");

      if (isQrMode.value && currentImageUrl.isNotEmpty) {
        analyzeQrCode(currentImageUrl.value);
      }
    } else {
      print("PaymentFlowController initialized with NO ARGUMENTS");
    }
  }

  @override
  void onClose() {
    adjustmentController.dispose();
    vpaController.dispose();
    accountHolderController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    remarksController.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Navigation Helpers
  // ---------------------------------------------------------------------------

  void _navigateToSuccess(Map<String, dynamic> data) {
    Get.offNamed(
      AppRoutes.ACCOUNTANT_PAYMENT_SUCCESS,
      arguments: {
        'amount': data['amount'] ?? finalAmount.value,
        'txnId': data['payment_id'] ?? 'N/A',
        'payee': scannedDetails['pn'] ?? vpaController.text, // Or requestor name
        'date': DateTime.now().toIso8601String(),
        'paymentSource': 'Bank Transfer',
        'mode': 'Online',
      },
    );
  }

  void prepareForView({
    required String url,
    required String title,
    bool isQr = false,
  }) {
    print("Preparing View: URL=$url, Title=$title, IsQR=$isQr");
    currentImageUrl.value = url;
    currentTitle.value = title;
    isQrMode.value = isQr;

    // Clear previous scan results
    isQrDetected.value = false;
    scannedDetails.clear();
    isScanning.value = false;
    _currentPayoutId = null;

    if (isQr && url.isNotEmpty) {
      analyzeQrCode(url);
    }
  }

  Future<File?> _downloadImage(String url) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/qr_temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Dio().download(url, filePath);
      return File(filePath);
    } catch (e) {
      print("Error downloading QR: $e");
      return null;
    }
  }

  Future<void> analyzeQrCode(String imageUrl) async {
    isScanning.value = true;
    isQrDetected.value = false;
    scannedDetails.clear();

    try {
      final file = await _downloadImage(imageUrl);
      if (file == null) {
        Get.snackbar('Error', 'Failed to load QR image');
        isScanning.value = false;
        return;
      }

      final MobileScannerController controller = MobileScannerController();
      final BarcodeCapture? capture = await controller.analyzeImage(file.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? rawValue = capture.barcodes.first.rawValue;
        if (rawValue != null) {
          _validateAndParseUpi(rawValue);
        } else {
          Get.snackbar('Invalid QR', 'No data found in QR code');
        }
      } else {
        Get.snackbar('Error', 'Could not detect QR code');
      }
    } catch (e) {
      print("QR Analysis Error: $e");
      Get.snackbar('Error', 'Failed to analyze QR code');
    } finally {
      isScanning.value = false;
    }
  }

  void _validateAndParseUpi(String uriString) {
    if (!uriString.startsWith('upi://pay')) {
      Get.snackbar('Invalid QR', 'This is not a valid Payment QR');
      return;
    }

    try {
      final uri = Uri.parse(uriString);
      final params = uri.queryParameters;

      final pa = params['pa'] ?? ''; // Payee Address
      final pn = params['pn'] ?? ''; // Payee Name
      final am = params['am'] ?? ''; // Amount

      if (pa.isEmpty) {
        Get.snackbar('Invalid QR', 'Missing Payee Address (VPA)');
        return;
      }

      // Amount validation
      double? parsedAmt;
      if (am.isNotEmpty) {
        parsedAmt = double.tryParse(am);
        if (parsedAmt != null) {
          if ((parsedAmt - requestedAmount.value).abs() > 0.01) {
            Get.snackbar(
              'Amount Mismatch',
              'QR Amount (₹$parsedAmt) does not match Request Amount (₹${requestedAmount.value})',
              backgroundColor: Colors.orange.withOpacity(0.9),
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          }
          finalAmount.value = parsedAmt;
        }
      }

      // Store scanned details
      final newDetails = <String, String>{};
      params.forEach((key, value) {
        newDetails[key] = value;
      });

      newDetails['pa'] = pa;
      newDetails['pn'] = pn;
      newDetails['am'] = am;
      newDetails['uri'] = uriString;

      scannedDetails.value = newDetails;
      isQrDetected.value = true;

      // Pre-fill VPA field
      vpaController.text = pa;
    } catch (e) {
      Get.snackbar('Error', 'Failed to parse UPI QR');
    }
  }

  void _navigateToFailure(Map<String, dynamic> statusResponse) {
    Get.offNamed(
      AppRoutes.ACCOUNTANT_PAYMENT_FAILED,
      arguments: {
        'amount': statusResponse['amount'] ?? finalAmount.value,
        'error': statusResponse['message'] ??
            statusResponse['error'] ??
            'Payment ${statusResponse['status'] ?? 'failed'}',
        'payee': statusResponse['beneficiary_name'] ??
            scannedDetails['pn'] ??
            vpaController.text,
        'date': statusResponse['initiated_at'] ?? DateTime.now().toIso8601String(),
        'txnId': statusResponse['payout_id'] ??
            statusResponse['payout_id'] ??
            'N/A',
      },
    );
  }

  /// Stub called by ConfirmPaymentView — no-op until new payment gateway is wired.
  /// The UI keeps the payment form functional; this prevents a compile error.
  void initiateRazorpayPayout() {
    Get.snackbar(
      'Coming Soon',
      'Payment gateway is currently disabled. Please use manual transfer.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> markAsPaid() async {
    final id = currentRequest['id'];
    if (id == null) {
      Get.snackbar('Error', 'Invalid Request ID');
      return;
    }

    try {
      isLoading.value = true;
      await _paymentRepository.markAsPaid(id);
      
      Get.snackbar(
        'Success',
        'Request marked as paid successfully',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
      
      // Refresh the dashboard data
      if (Get.isRegistered<AccountantPaymentsController>()) {
        final acctController = Get.find<AccountantPaymentsController>();
        acctController.fetchPendingPayments();
        acctController.fetchCompletedPayments();
      }
      
      Get.back(); // Return to list
    } catch (e) {
      print("Error marking as paid: $e");
      Get.snackbar(
        'Error',
        'Failed to mark as paid: $e',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void backToDashboard() {
    Get.offAllNamed(AppRoutes.ACCOUNTANT_DASHBOARD);
  }
}
