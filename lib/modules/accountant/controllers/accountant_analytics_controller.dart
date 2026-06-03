import 'dart:io';
import 'package:dio/dio.dart' show DioException;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/services/network_service.dart';
import '../../../../data/repositories/accountant_repository.dart';
import '../../../../data/models/accountant_reports_model.dart';
import '../views/widgets/date_range_picker_dialog.dart';
import 'accountant_dashboard_controller.dart';

class AccountantAnalyticsController extends GetxController {
  late final AccountantRepository _repository;

  // State Variables
  final Rx<ReportSummaryModel?> reportSummary = Rx<ReportSummaryModel?>(null);
  final Rx<SpendAnalyticsModel?> spendAnalytics = Rx<SpendAnalyticsModel?>(null);

  final RxBool isReportLoading = false.obs;
  final RxBool isSpendLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Reports/exports backend endpoints exist (/accountant/reports/summary,
  // /accountant/reports/export/{csv,pdf}). Flags are kept so a runtime 404
  // can still degrade gracefully, but they default to "available".
  final RxBool reportsAvailable = true.obs;
  final RxBool exportsAvailable = true.obs;
  final RxString reportsMessage = ''.obs;

  // Filters
  final selectedTimeRange = 'This Month'.obs;
  final selectedDepartment = 'Department'.obs;
  final selectedCategory = 'Category'.obs;

  // Financial Reports Filters
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  final reportCategory = 'All Categories'.obs;

  /// Set by [loadIfNeeded] so we only hit the backend the first time the
  /// Reports tab is opened. Subsequent visits reuse the cached data; pull-
  /// to-refresh and filter changes still re-fetch explicitly.
  bool _hasLoaded = false;

  // Reports-tab index in the accountant bottom nav.
  static const int _reportsTabIndex = 2;

  @override
  void onInit() {
    super.onInit();
    _repository = AccountantRepository(Get.find<NetworkService>());

    // Reactive trigger: whenever the dashboard's bottom-nav lands on the
    // Reports tab, fire the analytics + reports fetches. This avoids
    // depending on the manual `onBottomNavTap(2)` path — works even if the
    // user lands on Reports via a deep link or a Get.toNamed shortcut.
    if (Get.isRegistered<AccountantDashboardController>()) {
      final dashCtrl = Get.find<AccountantDashboardController>();
      // If the user is already on Reports when this controller spins up
      // (rare, but possible during hot reload), kick off the load now.
      if (dashCtrl.rxIndex.value == _reportsTabIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) => loadIfNeeded());
      }
      ever<int>(dashCtrl.rxIndex, (idx) {
        if (idx == _reportsTabIndex) loadIfNeeded();
      });
    }
  }

  /// Triggered by the dashboard's bottom-nav handler when the Reports tab
  /// becomes active. Idempotent — first call fires the fetches, subsequent
  /// calls no-op. Use [refreshAll] for forced refreshes.
  void loadIfNeeded() {
    if (_hasLoaded) return;
    _hasLoaded = true;
    debugPrint('[Analytics] loadIfNeeded — firing initial fetches');
    fetchSpendAnalytics();
    generatePreview();
  }

  /// Force a refresh regardless of the cache flag (pull-to-refresh, filter
  /// change, etc.).
  Future<void> refreshAll() async {
    _hasLoaded = true;
    await Future.wait([fetchSpendAnalytics(), generatePreview()]);
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
    final DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => AppDateRangePickerDialog(
        initialStart: startDate.value,
        initialEnd: endDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
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
      debugPrint('[Analytics] /accountant/analytics/spend keys: ${res.keys.toList()}');
      spendAnalytics.value = SpendAnalyticsModel.fromJson(res);
    } catch (e) {
      _surfaceError('spend analytics', e);
      errorMessage.value = 'Failed to load spend analytics';
    } finally {
      isSpendLoading.value = false;
    }
  }

  void _surfaceError(String label, Object e) {
    if (e is DioException) {
      debugPrint('[Analytics] $label FAILED');
      debugPrint('  url: ${e.requestOptions.uri}');
      debugPrint('  status: ${e.response?.statusCode}');
      debugPrint('  body: ${e.response?.data}');
      debugPrint('  type: ${e.type}');
    } else {
      debugPrint('[Analytics] $label FAILED: $e');
    }
    final detail = e is DioException
        ? '${e.response?.statusCode ?? "?"} ${e.response?.data ?? e.message ?? e.type}'
        : e.toString();
    Get.snackbar(
      'Reports error',
      'Failed to load $label — $detail',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 6),
    );
  }

  Future<void> generatePreview() async {
    isReportLoading.value = true;
    errorMessage.value = '';
    reportsMessage.value = '';
    try {
      // By default pass month and year of the startDate.
      final res = await _repository.getReportsSummary(
        month: startDate.value.month,
        year: startDate.value.year,
        category: reportCategory.value,
      );
      debugPrint('[Analytics] /accountant/reports/summary keys: ${res.keys.toList()}');
      reportSummary.value = ReportSummaryModel.fromJson(res);
      reportsAvailable.value = true;
    } catch (e) {
      _surfaceError('reports summary', e);
      if (e is DioException && e.response?.statusCode == 404) {
        reportsAvailable.value = false;
        reportsMessage.value = 'Reports not available yet';
        reportSummary.value = null;
      } else {
        errorMessage.value = 'Failed to load report summary';
      }
    } finally {
      isReportLoading.value = false;
    }
  }

  // Common export utility calling backend
  Future<void> _exportDocument({required bool isPdf}) async {
    final kind = isPdf ? 'PDF' : 'CSV';

    if (!exportsAvailable.value) {
      Get.snackbar('Coming soon', 'Export is coming soon.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      Get.snackbar('Exporting', 'Preparing $kind for download…',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));

      String d(DateTime x) =>
          '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
      final startStr = d(startDate.value);
      final endStr = d(endDate.value);

      debugPrint('[Export] requesting $kind  $startStr → $endStr  cat=${reportCategory.value}');

      final bytes = isPdf
          ? await _repository.exportPdf(
              startDate: startStr, endDate: endStr, category: reportCategory.value)
          : await _repository.exportCsv(
              startDate: startStr, endDate: endStr, category: reportCategory.value);

      if (bytes.isEmpty) {
        debugPrint('[Export] backend returned 0 bytes');
        Get.snackbar('No data', 'Server returned an empty $kind for the selected range.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.black87);
        return;
      }

      // Use cache dir (works with open_file's bundled FileProvider) and an
      // extensionless prefix so multiple exports don't collide.
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'Cashora_Report_${DateTime.now().millisecondsSinceEpoch}.${isPdf ? "pdf" : "csv"}';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      debugPrint('[Export] wrote ${bytes.length}B to ${file.path}');

      final mime = isPdf ? 'application/pdf' : 'text/csv';
      final result = await OpenFile.open(file.path, type: mime);
      debugPrint('[Export] OpenFile result: type=${result.type} message=${result.message}');

      switch (result.type) {
        case ResultType.done:
          Get.snackbar(
            'Success',
            '$kind opened',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: const Icon(Icons.check_circle, color: Color(0xFF22C55E)),
          );
          break;
        case ResultType.noAppToOpen:
          Get.snackbar(
            'Saved — no viewer',
            'No app on this device can open $kind. File is saved at:\n${file.path}',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.black87,
          );
          break;
        case ResultType.permissionDenied:
          Get.snackbar('Permission denied',
              'The OS blocked opening the file. Saved at: ${file.path}',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red.shade100, colorText: Colors.red);
          break;
        case ResultType.fileNotFound:
          Get.snackbar('File missing',
              'Wrote ${bytes.length}B but file disappeared before open',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100, colorText: Colors.red);
          break;
        case ResultType.error:
          Get.snackbar('Open failed', result.message,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red.shade100, colorText: Colors.red);
          break;
      }
    } catch (e) {
      _surfaceError('export', e);
      Get.snackbar('Error', 'Failed to export document. Please try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void exportCsv() => _exportDocument(isPdf: false);
  void exportPdf() => _exportDocument(isPdf: true);
}
