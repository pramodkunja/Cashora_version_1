import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:typed_data';

/// Service to handle QR code scanning and processing
class QRService extends GetxService {
  /// Scan QR code from image file
  /// Returns the QR code data as a string, or null if no QR code found
  Future<String?> scanQRFromFile(XFile file) async {
    try {
      // Read file as bytes
      final Uint8List bytes = await file.readAsBytes();
      
      // Create a mobile scanner controller
      final controller = MobileScannerController();
      
      // Note: mobile_scanner primarily works with camera
      // For file-based scanning, we'll need to use a different approach
      // This is a placeholder - actual implementation may vary based on package
      
      // For now, we'll return a mock implementation
      // In production, you might want to use a different QR scanning package
      // that supports file-based scanning, such as 'qr_code_tools' or 'scan'
      
      print('⚠️ QR scanning from file not fully implemented');
      print('   Consider using a package like qr_code_tools for file-based scanning');
      
      // Dispose controller
      controller.dispose();
      
      return null;
    } catch (e) {
      print('❌ Error scanning QR code: $e');
      return null;
    }
  }

  /// Validate if QR data contains payment information
  bool isPaymentQR(String qrData) {
    // Check for UPI format
    if (qrData.startsWith('upi://pay')) {
      return true;
    }
    
    // Check for UPI ID format
    if (qrData.contains('@') && qrData.split('@').length == 2) {
      return true;
    }
    
    // Check for bank account number (9-18 digits)
    final accountRegex = RegExp(r'\d{9,18}');
    if (accountRegex.hasMatch(qrData)) {
      return true;
    }
    
    return false;
  }

  /// Extract UPI details from QR data
  Map<String, String?> extractUPIDetails(String qrData) {
    final details = <String, String?>{
      'pa': null, // Payee address (VPA)
      'pn': null, // Payee name
      'mc': null, // Merchant code
      'tid': null, // Transaction ID
      'tr': null, // Transaction reference
      'tn': null, // Transaction note
      'am': null, // Amount
      'cu': null, // Currency
    };

    try {
      // Parse UPI URL format: upi://pay?pa=xxx@xxx&pn=Name&...
      if (qrData.startsWith('upi://pay')) {
        final uri = Uri.parse(qrData);
        uri.queryParameters.forEach((key, value) {
          if (details.containsKey(key)) {
            details[key] = value;
          }
        });
      } else if (qrData.contains('@')) {
        // Simple VPA format
        details['pa'] = qrData.trim();
      }
    } catch (e) {
      print('Error extracting UPI details: $e');
    }

    return details;
  }

  /// Extract bank account details from QR data
  Map<String, String?> extractBankDetails(String qrData) {
    final details = <String, String?>{
      'accountNumber': null,
      'ifsc': null,
      'name': null,
    };

    try {
      // This is a simplified extraction
      // Actual implementation depends on QR format used by banks
      
      // Extract account number (9-18 digits)
      final accountRegex = RegExp(r'\d{9,18}');
      final accountMatch = accountRegex.firstMatch(qrData);
      if (accountMatch != null) {
        details['accountNumber'] = accountMatch.group(0);
      }

      // Extract IFSC code (format: ABCD0123456)
      final ifscRegex = RegExp(r'[A-Z]{4}0[A-Z0-9]{6}');
      final ifscMatch = ifscRegex.firstMatch(qrData);
      if (ifscMatch != null) {
        details['ifsc'] = ifscMatch.group(0);
      }
    } catch (e) {
      print('Error extracting bank details: $e');
    }

    return details;
  }

  /// Determine payment type from QR data
  String getPaymentType(String qrData) {
    if (qrData.startsWith('upi://') || qrData.contains('@')) {
      return 'upi';
    }
    
    final accountRegex = RegExp(r'\d{9,18}');
    if (accountRegex.hasMatch(qrData)) {
      return 'bank_account';
    }
    
    return 'unknown';
  }
}
