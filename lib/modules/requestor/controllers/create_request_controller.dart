import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cash/data/repositories/request_repository.dart';
import 'package:cash/data/repositories/organization_repository.dart';
import '../../../../core/services/network_service.dart';
import '../../../utils/validators.dart';

class CreateRequestController extends GetxController {
  late final RequestRepository _requestRepository;
  late final OrganizationRepository _orgRepository;
  final ImagePicker _picker = ImagePicker();

  // Observable state
  final requestType = 'Post-approved'.obs;
  final amount = 0.0.obs;
  final deemedLimit = 0.0.obs; // Dynamic limit
  final category =
      'Deemed'.obs; // Auto-calculated status (Deemed/Approval Required)
  final purpose = ''.obs;
  final description = ''.obs;
  final paymentNote = ''.obs;
  final attachedFiles = <XFile>[].obs; // Bills
  final qrFile = Rxn<XFile>(); // Single QR
  final receiptFile = Rxn<XFile>(); // Single Receipt (for Post-approved)
  final isLoading = false.obs;

  // UPI extracted from QR
  final extractedVpa = ''.obs;
  final isExtractingQr = false.obs;

  // New Expense Category Logic
  final selectedExpenseCategory = Rxn<Map<String, dynamic>>();
  final expenseCategories = <Map<String, dynamic>>[].obs;

  // ... (existing helper methods fetchCategories, fetchLimit, onInit) ...

  Future<void> fetchCategories() async {
    try {
      final categoriesProxy = await _requestRepository.getCategories();

      final Map<String, IconData> iconMap = {
        'travel': Icons.flight,
        'meals': Icons.restaurant,
        'software': Icons.computer,
        'office_supplies': Icons.shopping_bag,
        'others': Icons.category,
        'transport': Icons.directions_car,
        'accommodation': Icons.hotel,
        'entertainment': Icons.movie,
      };

      final List<Map<String, dynamic>> mappedCategories = categoriesProxy.map((
        catString,
      ) {
        // Format name: "office_supplies" -> "Office Supplies"
        String name = catString
            .split('_')
            .map(
              (word) => word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
            )
            .join(' ');

        return {
          'name': name,
          'id': catString, // Keep original ID for API
          'icon': iconMap[catString] ?? Icons.circle,
        };
      }).toList();

      expenseCategories.value = mappedCategories;
    } catch (e) {
      print("Failed to load categories: $e");
    }
  }

  Future<void> fetchLimit() async {
    try {
      final response = await _orgRepository.getApprovalLimits();
      if (response != null) {
        // Handle backend response keys
        var val =
            response['deemed_approval_limit'] ?? response['deemed_limit'] ?? 0;
        deemedLimit.value = (val is int)
            ? val.toDouble()
            : (val as double? ?? 0.0);
      }
    } catch (e) {
      print("Failed to fetch limits: $e");
    }
  }

  // Text Controllers
  final amountController = TextEditingController();
  final purposeController = TextEditingController();
  final descriptionController = TextEditingController();
  final paymentNoteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _requestRepository = RequestRepository(Get.find<NetworkService>());
    _orgRepository = OrganizationRepository(Get.find<NetworkService>());
    fetchCategories();
    fetchLimit();

    amountController.addListener(() {
      final val =
          double.tryParse(amountController.text.replaceAll(',', '')) ?? 0.0;
      amount.value = val;
      // Use dynamic limit, default to 1000 if 0 (not fetched yet)
      final limit = deemedLimit.value > 0 ? deemedLimit.value : 1000.0;

      if (val > limit) {
        category.value = 'Approval Required';
      } else {
        category.value = 'Deemed';
      }
    });

    purposeController.addListener(() {
      purpose.value = purposeController.text;
    });

    descriptionController.addListener(() {
      description.value = descriptionController.text;
    });

    paymentNoteController.addListener(() {
      paymentNote.value = paymentNoteController.text;
    });
  }

  // ... class definition ...

  Future<void> pickImage(
    ImageSource source, {
    bool isQr = false,
    bool isReceipt = false,
  }) async {
    // Get.snackbar('Debug', 'Opening picker...', duration: const Duration(seconds: 1), snackPosition: SnackPosition.BOTTOM);

    XFile? pickedFile;

    // 1. Web
    if (kIsWeb) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );

        if (result != null && result.files.single.bytes != null) {
          pickedFile = XFile.fromData(
            result.files.single.bytes!,
            name: result.files.single.name,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to pick image on Web: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
        return;
      }
    }
    // 2. Desktop
    else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          pickedFile = XFile(result.files.single.path!);
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to pick image on Desktop: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
        return;
      }
    }
    // 3. Mobile
    else {
      // Logic for permissions...
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        if (await Permission.photos.status.isGranted ||
            await Permission.mediaLibrary.status.isGranted) {
          status = PermissionStatus.granted;
        } else if (await Permission.storage.isGranted) {
          status = PermissionStatus.granted;
        } else {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.storage,
            Permission.photos,
            Permission.mediaLibrary,
          ].request();
          if (statuses.values.any((s) => s.isGranted)) {
            status = PermissionStatus.granted;
          } else {
            status = PermissionStatus.denied;
          }
        }
      }

      if (status.isGranted || status.isLimited) {
        try {
          pickedFile = await _picker.pickImage(source: source);
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to pick image: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
          );
          return;
        }
      } else if (status.isPermanentlyDenied) {
        Get.dialog(
          AlertDialog(
            title: const Text('Permission Required'),
            content: const Text('Please enable permissions in settings.'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Get.back(),
              ),
              TextButton(
                child: const Text('Settings'),
                onPressed: () {
                  Get.back();
                  openAppSettings();
                },
              ),
            ],
          ),
        );
        return;
      } else {
        Get.snackbar(
          'Permission Denied',
          'Permission required.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Process picked file
    if (pickedFile != null) {
      if (isQr) {
        // Validate QR file before accepting
        final validation = await FileValidator.validateQRUploadWithSize(pickedFile);
        if (!validation.isValid) {
          Get.snackbar(
            'Invalid QR Image',
            validation.errors.join('\n'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
            duration: const Duration(seconds: 4),
          );
          return;
        }
        qrFile.value = pickedFile;
      } else if (isReceipt) {
        receiptFile.value = pickedFile;
      } else {
        attachedFiles.add(pickedFile);
      }
    }
  }

  void removeFile(int index) {
    if (index >= 0 && index < attachedFiles.length) {
      attachedFiles.removeAt(index);
    }
  }

  void removeQr() {
    qrFile.value = null;
    extractedVpa.value = '';
  }

  void removeReceipt() {
    receiptFile.value = null;
  }

  bool validateRequest() {
    if (requestType.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a request type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (amount.value <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (selectedExpenseCategory.value == null) {
      Get.snackbar(
        'Error',
        'Please select a category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (purpose.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a purpose for the request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }

  Future<void> submitRequest() async {
    if (!validateRequest()) return;

    try {
      isLoading.value = true;

      // Map UI values to API expected format
      final apiRequestType = requestType.value == 'Pre-approved'
          ? 'pre_approved'
          : 'post_approved';
      final apiCategory =
          selectedExpenseCategory.value?['id'] ??
          (selectedExpenseCategory.value?['name'] as String)
              .toLowerCase()
              .replaceAll(' & ', '_')
              .replaceAll(' ', '_');

      final response = await _requestRepository.submitRequest(
        requestType: apiRequestType,
        amount: amount.value,
        purpose: purpose.value,
        description: description.value,
        category: apiCategory,
        paymentNote: paymentNote.value.isNotEmpty ? paymentNote.value : null,
        qrFile: qrFile.value,
        receiptFile: receiptFile.value,
        billFiles: attachedFiles,
      );

      // Navigate to success, passing the status/response
      // The previous code had '/create-request/success'. We should check if we can pass arguments or if the success view controller reads arguments.
      // I'll assume we pass 'status' and 'amount'.

      Get.offAllNamed(
        '/create-request/success',
        arguments: {
          'status': response['status'], // 'auto_approved' or 'pending'
          'payment_status': response['payment_status'], // Fetch from response
          'amount': response['amount'],
          'request_id': response['request_id'],
          'category': selectedExpenseCategory.value?['name'],
          'purpose': purpose.value,
          'description': description.value,
          'date': DateTime.now().toString(), // Current date
          'attachments': attachedFiles
              .map(
                (file) => {
                  'name': file.name,
                  'size':
                      'Unknown', // File size might need async read, skip for now or 'Unknown'
                  'type': 'image', // Assuming images for now
                  'path': file.path, // Or bytes reference if needed
                  'file': file, // Pass XFile object for valid reference
                },
              )
              .toList(),
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit request: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    purposeController.dispose();
    descriptionController.dispose();
    paymentNoteController.dispose();
    super.onClose();
  }
}
