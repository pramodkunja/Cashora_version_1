import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../data/repositories/department_repository.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/app_loader.dart';

class DepartmentController extends GetxController {
  final DepartmentRepository _repository = Get.find<DepartmentRepository>();

  final departments = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final showInactive = false.obs;

  // Form
  final nameController = TextEditingController();
  final codeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    super.onClose();
  }

  Future<void> fetchDepartments() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.listDepartments(
        includeInactive: showInactive.value,
      );
      departments.assignAll(result);
    } catch (e) {
      errorMessage.value = _extractError(e, 'Failed to load departments');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleInactive(bool value) {
    showInactive.value = value;
    fetchDepartments();
  }

  // --- Seed Defaults ---------------------------------------------------------

  Future<void> seedDefaults() async {
    try {
      Get.dialog(const Center(child: AppSpinner()), barrierDismissible: false);
      final result = await _repository.seedDefaults();
      Get.back();

      final created = (result['created'] as List?)?.join(', ') ?? '';
      final skipped = (result['skipped'] as List?)?.join(', ') ?? '';

      String msg = '';
      if (created.isNotEmpty) msg += 'Created: $created';
      if (skipped.isNotEmpty) {
        if (msg.isNotEmpty) msg += '\n';
        msg += 'Already exist: $skipped';
      }
      if (msg.isEmpty) msg = result['message']?.toString() ?? 'Done';

      Get.snackbar(
        'Seed Defaults',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successGreen,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );

      await fetchDepartments();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        _extractError(e, 'Failed to seed defaults'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
    }
  }

  // --- Create ----------------------------------------------------------------

  void showCreateDialog() {
    nameController.clear();
    codeController.clear();
    Get.dialog(_buildFormDialog(isEdit: false));
  }

  Future<void> createDepartment() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Department name is required',
          backgroundColor: Colors.red.shade100, colorText: Colors.red);
      return;
    }

    try {
      Get.dialog(const Center(child: AppSpinner()), barrierDismissible: false);
      await _repository.createDepartment(
        name: name,
        code: codeController.text.trim().isEmpty
            ? null
            : codeController.text.trim(),
      );
      Get.back(); // loader
      Get.back(); // dialog

      Get.snackbar('Success', 'Department "$name" created',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));

      await fetchDepartments();
    } catch (e) {
      Get.back(); // loader
      Get.snackbar('Error', _extractError(e, 'Failed to create department'),
          backgroundColor: Colors.red.shade100, colorText: Colors.red);
    }
  }

  // --- Edit ------------------------------------------------------------------

  void showEditDialog(Map<String, dynamic> dept) {
    nameController.text = dept['name']?.toString() ?? '';
    codeController.text = dept['code']?.toString() ?? '';
    Get.dialog(_buildFormDialog(isEdit: true, departmentId: dept['id']));
  }

  Future<void> updateDepartment(int id) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Department name is required',
          backgroundColor: Colors.red.shade100, colorText: Colors.red);
      return;
    }

    try {
      Get.dialog(const Center(child: AppSpinner()), barrierDismissible: false);
      await _repository.updateDepartment(
        id,
        name: name,
        code: codeController.text.trim().isEmpty
            ? null
            : codeController.text.trim(),
      );
      Get.back(); // loader
      Get.back(); // dialog

      Get.snackbar('Success', 'Department updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));

      await fetchDepartments();
    } catch (e) {
      Get.back(); // loader
      Get.snackbar('Error', _extractError(e, 'Failed to update department'),
          backgroundColor: Colors.red.shade100, colorText: Colors.red);
    }
  }

  // --- Delete (soft) ---------------------------------------------------------

  Future<void> deleteDepartment(int id, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Deactivate Department'),
        content: Text('Deactivate "$name"? Users assigned to it will become unassigned.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Deactivate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      Get.dialog(const Center(child: AppSpinner()), barrierDismissible: false);
      await _repository.deleteDepartment(id);
      Get.back();

      Get.snackbar('Success', '"$name" deactivated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));

      await fetchDepartments();
    } catch (e) {
      Get.back();
      Get.snackbar('Error', _extractError(e, 'Failed to deactivate department'),
          backgroundColor: Colors.red.shade100, colorText: Colors.red);
    }
  }

  // --- Shared ----------------------------------------------------------------

  Widget _buildFormDialog({required bool isEdit, int? departmentId}) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit Department' : 'New Department',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g. Marketing',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Code (optional)',
                hintText: 'e.g. MKT',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isEdit
                        ? () => updateDepartment(departmentId!)
                        : createDepartment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isEdit ? 'Update' : 'Create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _extractError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
      if (data is Map && data['message'] != null) return data['message'].toString();
      final code = e.response?.statusCode;
      if (code == 400) return 'Department name or code already exists.';
      if (code == 401) return 'Session expired. Please log in again.';
      if (code == 403) return 'Admin access required.';
      if (code == 404) return 'Department not found.';
    }
    return fallback;
  }
}
