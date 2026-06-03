import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import '../../../../data/repositories/department_repository.dart';
import '../../../../utils/app_colors.dart';

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
      Get.dialog(
        const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        barrierDismissible: false,
      );
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
      Get.dialog(
        const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        barrierDismissible: false,
      );
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
      Get.dialog(
        const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        barrierDismissible: false,
      );
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
      Get.dialog(
        const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        barrierDismissible: false,
      );
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

  // --- Reactivate (un-soft-delete) -------------------------------------------

  Future<void> reactivateDepartment(int id, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reactivate Department'),
        content: Text('Reactivate "$name"? It will be available for assignment again.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Reactivate',
                style: TextStyle(color: AppColors.successGreen)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        barrierDismissible: false,
      );
      await _repository.updateDepartment(id, isActive: true);
      Get.back();

      Get.snackbar('Success', '"$name" reactivated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));

      await fetchDepartments();
    } catch (e) {
      Get.back();
      Get.snackbar('Error',
          _extractError(e, 'Failed to reactivate department'),
          backgroundColor: Colors.red.shade100, colorText: Colors.red);
    }
  }

  // --- Shared ----------------------------------------------------------------

  Widget _buildFormDialog({required bool isEdit, int? departmentId}) {
    const Color ink900 = Color(0xFF0F172A);
    const Color ink700 = Color(0xFF334155);
    const Color ink500 = Color(0xFF64748B);
    const Color ink300 = Color(0xFFCBD5E1);
    const Color ink200 = Color(0xFFE2E8F0);
    const Color surface = Color(0xFFF8FAFC);

    InputDecoration deco({required String label, required IconData icon}) {
      return InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: ink500,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 12.w, right: 6.w),
          child: Icon(icon, color: ink500, size: 18.sp),
        ),
        prefixIconConstraints:
            BoxConstraints(minWidth: 36.w, minHeight: 36.h),
        filled: true,
        fillColor: surface,
        isDense: true,
        hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: ink300),
        contentPadding:
            EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: ink200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: ink200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.8),
        ),
      );
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 32.r,
                offset: Offset(0, 12.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gradient accent strip
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 22.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero icon + close
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              width: 1.4,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 14.r,
                                  offset: Offset(0, 6.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              isEdit
                                  ? Icons.edit_rounded
                                  : Icons.apartment_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Material(
                          color: surface,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Get.back(),
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Icon(Icons.close_rounded,
                                  color: ink500, size: 18.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Eyebrow pill
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        isEdit ? 'EDIT DEPARTMENT' : 'NEW DEPARTMENT',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Title
                    Text(
                      isEdit ? 'Update department' : 'Create a department',
                      style: GoogleFonts.outfit(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: ink900,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isEdit
                          ? 'Update the name or code for this department.'
                          : 'Group users and budgets under a department.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: ink500,
                        height: 1.45,
                      ),
                    ),

                    SizedBox(height: 22.h),

                    // Name input
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.inter(
                          fontSize: 14.sp, color: ink900),
                      cursorColor: AppColors.primary,
                      decoration: deco(
                        label: 'Name *',
                        icon: Icons.apartment_rounded,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    // Code input
                    TextField(
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.inter(
                          fontSize: 14.sp, color: ink900),
                      cursorColor: AppColors.primary,
                      decoration: deco(
                        label: 'Code (optional)',
                        icon: Icons.qr_code_rounded,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Action row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: ink200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                backgroundColor: surface,
                                foregroundColor: ink700,
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: ink700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.40),
                                  blurRadius: 16.r,
                                  offset: Offset(0, 8.h),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isEdit
                                    ? () => updateDepartment(departmentId!)
                                    : createDepartment,
                                borderRadius: BorderRadius.circular(14.r),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isEdit
                                            ? Icons.check_rounded
                                            : Icons.add_rounded,
                                        color: Colors.white,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        isEdit ? 'Update' : 'Create',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
