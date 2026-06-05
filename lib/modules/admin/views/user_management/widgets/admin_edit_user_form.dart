import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import '../../../controllers/admin_user_controller.dart';

/// The white rounded form sheet for Admin → Edit User. Contains personal
/// info fields, role + department dropdowns, and the update / deactivate
/// action buttons.
class AdminEditUserForm extends StatelessWidget {
  final AdminUserController controller;
  final double bottomInset;
  final bool isActive;

  const AdminEditUserForm({
    super.key,
    required this.controller,
    required this.bottomInset,
    required this.isActive,
  });

  static const Color _bgB = Color(0xFFF8F7FF);
  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink200 = Color(0xFFE2E8F0);
  static const Color _green = AppColors.successGreen;
  static const Color _greenBg = Color(0xFFECFDF5);
  static const Color _red = AppColors.errorRed;
  static const Color _redBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36.r),
          topRight: Radius.circular(36.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 24.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 24.h + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHeader(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _floatingField(
                    label: AppText.firstName,
                    controller: controller.firstNameController,
                    icon: Icons.badge_outlined,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _floatingField(
                    label: AppText.lastName,
                    controller: controller.lastNameController,
                    icon: Icons.badge_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Tooltip(
              message: 'Email cannot be changed. Contact support to update.',
              child: _floatingField(
                label: AppText.emailAddress,
                controller: controller.emailController,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
            ),
            SizedBox(height: 14.h),
            _floatingField(
              label: AppText.phone,
              controller: controller.phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 22.h),
            _sectionHeader(
              icon: Icons.workspace_premium_outlined,
              title: 'Role & Department',
            ),
            SizedBox(height: 14.h),
            _buildRoleDropdown(),
            SizedBox(height: 14.h),
            _buildDepartmentDropdown(),
            SizedBox(height: 28.h),
            _buildUpdateButton(),
            SizedBox(height: 12.h),
            _buildDeactivateButton(isActive),
          ],
        ),
      ),
    );
  }

  // ─────────────────── SECTION HEADER ───────────────────

  Widget _sectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: _ink900,
          ),
        ),
      ],
    );
  }

  // ─────────────────── FIELDS ───────────────────

  Widget _floatingField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        color: readOnly ? _ink500 : _ink900,
      ),
      cursorColor: AppColors.primary,
      decoration: _decoration(label: label, icon: icon, readOnly: readOnly),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: _ink500,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: 12.w, right: 6.w),
        child: Icon(icon, color: _ink500, size: 18.sp),
      ),
      prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
      suffixIcon: suffix,
      filled: true,
      fillColor: readOnly ? _ink200.withValues(alpha: 0.35) : _bgB,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _ink200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _ink200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _ink200),
      ),
    );
  }

  // ─────────────────── DROPDOWNS ───────────────────

  Widget _buildRoleDropdown() {
    const roles = ['Admin', 'Requestor', 'Accountant'];
    return Obx(() {
      String? selected = controller.selectedRole.value;
      if (selected.isNotEmpty) {
        final match = roles.firstWhere(
          (r) => r.toLowerCase() == selected?.toLowerCase(),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          selected = match;
          if (selected != controller.selectedRole.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.selectedRole.value = match;
            });
          }
        } else {
          selected = null;
        }
      } else {
        selected = null;
      }
      return DropdownButtonFormField<String>(
        initialValue: selected,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _ink500,
          size: 22.sp,
        ),
        style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
        dropdownColor: Colors.white,
        decoration: _decoration(
          label: AppText.role,
          icon: Icons.badge_outlined,
        ),
        items: roles
            .map(
              (r) => DropdownMenuItem<String>(
                value: r,
                child: Text(
                  r,
                  style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
                ),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) controller.selectedRole.value = v;
        },
      );
    });
  }

  Widget _buildDepartmentDropdown() {
    return Obx(() {
      return DropdownButtonFormField<int?>(
        initialValue: controller.selectedDepartmentId.value,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _ink500,
          size: 22.sp,
        ),
        style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
        dropdownColor: Colors.white,
        decoration: _decoration(
          label: 'Department',
          icon: Icons.domain_rounded,
        ),
        items: [
          DropdownMenuItem<int?>(
            value: null,
            child: Text(
              'Unassigned',
              style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
            ),
          ),
          ...controller.departments.where((d) => d['is_active'] == true).map((
            d,
          ) {
            final id = d['id'] is int
                ? d['id'] as int
                : int.tryParse(d['id'].toString());
            final name = d['name']?.toString() ?? '';
            final code = d['code']?.toString() ?? '';
            return DropdownMenuItem<int?>(
              value: id,
              child: Text(
                code.isNotEmpty ? '$name ($code)' : name,
                style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
              ),
            );
          }),
        ],
        onChanged: (v) => controller.selectedDepartmentId.value = v,
      );
    });
  }

  // ─────────────────── BUTTONS ───────────────────

  Widget _buildUpdateButton() {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.updateUser,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save_rounded, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  AppText.updateUser,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeactivateButton(bool isActive) {
    final Color fg = isActive ? _red : _green;
    final Color bg = isActive ? _redBg : _greenBg;
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton.icon(
        onPressed: () => controller.confirmDeactivate(
          Map<String, dynamic>.from(controller.rxSelectedUser),
        ),
        icon: Icon(
          isActive ? Icons.block_rounded : Icons.check_circle_rounded,
          color: fg,
          size: 18.sp,
        ),
        label: Text(
          isActive ? AppText.deactivateUser : AppText.activateUser,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: fg.withValues(alpha: 0.30)),
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
