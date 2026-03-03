import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AccountantAnalyticsController extends GetxController {
  // Filters
  final selectedTimeRange = 'This Month'.obs;
  final selectedDepartment = 'Department'.obs;
  final selectedCategory = 'Category'.obs;

  // Financial Reports Filters
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final reportCategory = 'All Categories'.obs;

  void onTimeRangeChanged(String? val) =>
      selectedTimeRange.value = val ?? 'This Month';
  void onDepartmentChanged(String? val) =>
      selectedDepartment.value = val ?? 'Department';
  void onCategoryChanged(String? val) =>
      selectedCategory.value = val ?? 'Category';

  void onReportCategoryChanged(String? val) =>
      reportCategory.value = val ?? 'All Categories';

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
    }
  }

  void generatePreview() {
    // Simulate generation
    Get.snackbar('Processing', 'Generating report preview...');
  }

  void exportCsv() {
    Get.snackbar(
      'Success',
      'Report exported successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(
        0xFF1E293B,
      ), // Dark background matching image
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.check_circle,
        color: Color(0xFF22C55E),
      ), // Green success icon
      duration: const Duration(seconds: 3),
    );
  }

  void exportPdf() {
    Get.snackbar(
      'Success',
      'Report exported successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Color(0xFF22C55E)),
      duration: const Duration(seconds: 3),
    );
  }
}
