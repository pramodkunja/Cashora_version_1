import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/services/network_service.dart';
import '../../../../data/repositories/accountant_repository.dart';
import '../../../../data/models/accountant_reports_model.dart';

class AccountantAnalyticsController extends GetxController {
  late final AccountantRepository _repository;

  // State Variables
  final Rx<ReportSummaryModel?> reportSummary = Rx<ReportSummaryModel?>(null);
  final Rx<SpendAnalyticsModel?> spendAnalytics = Rx<SpendAnalyticsModel?>(null);

  final RxBool isReportLoading = false.obs;
  final RxBool isSpendLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filters
  final selectedTimeRange = 'This Month'.obs;
  final selectedDepartment = 'Department'.obs;
  final selectedCategory = 'Category'.obs;

  // Financial Reports Filters
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final reportCategory = 'All Categories'.obs;

  @override
  void onInit() {
    super.onInit();
    _repository = AccountantRepository(Get.find<NetworkService>());
  }

  @override
  void onReady() {
    super.onReady();
    fetchSpendAnalytics();
    generatePreview();
  }

  void onTimeRangeChanged(String? val) {
    selectedTimeRange.value = val ?? 'This Month';
    fetchSpendAnalytics();
  }

  void onDepartmentChanged(String? val) {
    selectedDepartment.value = val ?? 'Department';
    fetchSpendAnalytics();
  }

  void onCategoryChanged(String? val) {
    selectedCategory.value = val ?? 'Category';
    fetchSpendAnalytics();
  }

  void onReportCategoryChanged(String? val) {
    reportCategory.value = val ?? 'All Categories';
    generatePreview();
  }

  void pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: startDate.value,
        end: endDate.value,
      ),
    );
    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
      generatePreview();
    }
  }

  Future<void> fetchSpendAnalytics() async {
    isSpendLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _repository.getSpendAnalytics(
        timeRange: selectedTimeRange.value,
        department: selectedDepartment.value,
        category: selectedCategory.value,
      );
      spendAnalytics.value = SpendAnalyticsModel.fromJson(res);
    } catch (e) {
      errorMessage.value = 'Failed to load spend analytics';
    } finally {
      isSpendLoading.value = false;
    }
  }

  Future<void> generatePreview() async {
    isReportLoading.value = true;
    errorMessage.value = '';
    try {
      // By default pass month and year of the startDate.
      final res = await _repository.getReportsSummary(
        month: startDate.value.month,
        year: startDate.value.year,
        category: reportCategory.value,
      );
      reportSummary.value = ReportSummaryModel.fromJson(res);
    } catch (e) {
      errorMessage.value = 'Failed to load report summary';
    } finally {
      isReportLoading.value = false;
    }
  }

  // Common export utility calling backend
  Future<void> _exportDocument({required bool isPdf}) async {
    try {
      Get.snackbar('Exporting', 'Preparing document for download...',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));

      final startStr = "${startDate.value.year}-${startDate.value.month.toString().padLeft(2, '0')}-${startDate.value.day.toString().padLeft(2, '0')}";
      final endStr = "${endDate.value.year}-${endDate.value.month.toString().padLeft(2, '0')}-${endDate.value.day.toString().padLeft(2, '0')}";

      final bytes = isPdf
          ? await _repository.exportPdf(startDate: startStr, endDate: endStr, category: reportCategory.value)
          : await _repository.exportCsv(startDate: startStr, endDate: endStr, category: reportCategory.value);

      final tempDir = await getTemporaryDirectory();
      final extension = isPdf ? 'pdf' : 'csv';
      final fileName = 'Financial_Report_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      OpenFile.open(file.path);

      Get.snackbar(
        'Success',
        'Report exported successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Color(0xFF22C55E)),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to export document. Please try again.',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void exportCsv() => _exportDocument(isPdf: false);
  void exportPdf() => _exportDocument(isPdf: true);
}
