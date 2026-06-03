import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/network_service.dart';
import '../../../../data/repositories/accountant_repository.dart';

/// Controller for the Manage Balances screen on the accountant profile.
///
/// Handles three concerns:
///   1. Fetching today's current balance snapshot.
///   2. Updating opening (and optionally closing) balance + note.
///   3. Loading a history page of past balance snapshots.
class ManageBalancesController extends GetxController {
  late final AccountantRepository _repository;

  // Today's snapshot ----------------------------------------------------------
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final openingBalance = 0.0.obs;
  final closingBalance = 0.0.obs;
  final amountIn = 0.0.obs;
  final amountOut = 0.0.obs;
  final lastUpdatedAt = ''.obs;
  final note = ''.obs;
  final today = ''.obs;

  // History list --------------------------------------------------------------
  final history = <Map<String, dynamic>>[].obs;
  final isHistoryLoading = false.obs;

  // Edit form -----------------------------------------------------------------
  final openingController = TextEditingController();
  final closingController = TextEditingController();
  final noteController = TextEditingController();
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _repository = AccountantRepository(Get.find<NetworkService>());
  }

  @override
  void onReady() {
    super.onReady();
    refreshAll();
  }

  @override
  void onClose() {
    openingController.dispose();
    closingController.dispose();
    noteController.dispose();
    super.onClose();
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchCurrent(), fetchHistory()]);
  }

  Future<void> fetchCurrent() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repository.getCurrentBalance();
      openingBalance.value =
          (data['opening_balance'] as num?)?.toDouble() ?? 0.0;
      closingBalance.value =
          (data['closing_balance'] as num?)?.toDouble() ?? 0.0;
      amountIn.value = (data['amount_in'] as num?)?.toDouble() ?? 0.0;
      amountOut.value = (data['amount_out'] as num?)?.toDouble() ?? 0.0;
      lastUpdatedAt.value = data['last_updated_at']?.toString() ?? '';
      note.value = data['note']?.toString() ?? '';
      today.value = data['date']?.toString() ?? '';
      _seedForm();
    } catch (e) {
      errorMessage.value =
          _extractMessage(e, fallback: 'Failed to load current balance');
      if (kDebugMode) debugPrint('[Balances] fetchCurrent error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHistory() async {
    isHistoryLoading.value = true;
    try {
      final rows = await _repository.getBalanceHistory();
      history.assignAll(rows);
    } catch (e) {
      if (kDebugMode) debugPrint('[Balances] fetchHistory error: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  /// Push the current snapshot into the edit form so the user can tweak
  /// existing values rather than re-typing from scratch.
  void _seedForm() {
    openingController.text =
        openingBalance.value > 0 ? openingBalance.value.toStringAsFixed(2) : '';
    closingController.text =
        closingBalance.value > 0 ? closingBalance.value.toStringAsFixed(2) : '';
    noteController.text = note.value;
  }

  Future<bool> saveBalance() async {
    final openingText = openingController.text.trim();
    if (openingText.isEmpty) {
      Get.snackbar('Validation', 'Opening balance is required',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    final opening = double.tryParse(openingText);
    if (opening == null || opening < 0) {
      Get.snackbar('Validation', 'Opening balance must be a non-negative number',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    final closingText = closingController.text.trim();
    double? closing;
    if (closingText.isNotEmpty) {
      closing = double.tryParse(closingText);
      if (closing == null || closing < 0) {
        Get.snackbar(
          'Validation',
          'Closing balance must be a non-negative number',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    isSaving.value = true;
    try {
      await _repository.setBalance(
        openingBalance: opening,
        closingBalance: closing,
        note: noteController.text,
      );
      await refreshAll();
      Get.snackbar('Saved', 'Balance updated successfully',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        _extractMessage(e, fallback: 'Failed to update balance'),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  static String _extractMessage(Object e, {required String fallback}) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      final code = e.response?.statusCode;
      if (code == 401) return 'Session expired. Please log in again.';
      if (code == 403) return 'You do not have permission.';
      if (code == 404) return 'Balance endpoint not available yet.';
    }
    return fallback;
  }
}
