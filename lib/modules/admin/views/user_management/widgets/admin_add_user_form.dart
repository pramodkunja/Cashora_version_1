import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import '../../../controllers/admin_user_controller.dart';

class AdminAddUserForm extends StatefulWidget {
  const AdminAddUserForm({
    super.key,
    required this.controller,
    required this.bottomInset,
  });

  final AdminUserController controller;
  final double bottomInset;

  @override
  State<AdminAddUserForm> createState() => _AdminAddUserFormState();
}

class _AdminAddUserFormState extends State<AdminAddUserForm> {
  // Owned by State so it survives rebuilds (e.g. when the keyboard opens and
  // MediaQuery changes). A GlobalKey recreated on every build would tear down
  // the Form subtree and steal focus from the field being typed into.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AdminUserController get controller => widget.controller;
  double get bottomInset => widget.bottomInset;

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink300 = Color(0xFFCBD5E1);
  static const Color _ink200 = Color(0xFFE2E8F0);
  static const Color _surface = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(42.r),
          topRight: Radius.circular(42.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 28.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 24.h + bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: _ink200,
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                ),
              ),
              SizedBox(height: 22.h),

              // Personal Information
              _entranceWrap(
                duration: const Duration(milliseconds: 1000),
                child: _sectionHeader(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                ),
              ),
              SizedBox(height: 12.h),
              _entranceWrap(
                duration: const Duration(milliseconds: 1050),
                child: Row(
                  children: [
                    Expanded(
                      child: _floatingTextField(
                        controller: controller.firstNameController,
                        label: 'First name',
                        icon: Icons.badge_outlined,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _floatingTextField(
                        controller: controller.lastNameController,
                        label: 'Last name',
                        icon: Icons.badge_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              _entranceWrap(
                duration: const Duration(milliseconds: 1100),
                child: _floatingTextField(
                  controller: controller.emailController,
                  label: 'Email address',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 14.h),
              _entranceWrap(
                duration: const Duration(milliseconds: 1150),
                child: _floatingTextField(
                  controller: controller.phoneController,
                  label: 'Phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),

              SizedBox(height: 22.h),

              // Organization & Role
              _entranceWrap(
                duration: const Duration(milliseconds: 1200),
                child: _sectionHeader(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Organization & Role',
                ),
              ),
              SizedBox(height: 12.h),
              _entranceWrap(
                duration: const Duration(milliseconds: 1250),
                child: _buildRoleDropdown(),
              ),
              SizedBox(height: 14.h),
              _entranceWrap(
                duration: const Duration(milliseconds: 1300),
                child: _buildDepartmentDropdown(),
              ),

              SizedBox(height: 28.h),

              _entranceWrap(
                duration: const Duration(milliseconds: 1400),
                child: _buildCreateButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── SECTIONS ─────────────────────────

  Widget _sectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
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

  // ───────────────────────── FIELDS ─────────────────────────

  Widget _floatingTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
      cursorColor: AppColors.primary,
      decoration: _floatingLabelDecoration(label: label, icon: icon),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Required';
        return null;
      },
    );
  }

  Widget _buildRoleDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        initialValue: controller.selectedRole.value.isEmpty
            ? null
            : controller.selectedRole.value,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _ink500,
          size: 22.sp,
        ),
        style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
        dropdownColor: Colors.white,
        decoration: _floatingLabelDecoration(
          label: AppText.selectRole,
          icon: Icons.badge_outlined,
        ),
        items: ['Requestor', 'Accountant'].map((role) {
          return DropdownMenuItem<String>(
            value: role,
            child: Text(
              role,
              style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
            ),
          );
        }).toList(),
        onChanged: (v) => controller.selectedRole.value = v ?? '',
        validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Obx(
      () => DropdownButtonFormField<int?>(
        initialValue: controller.selectedDepartmentId.value,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _ink500,
          size: 22.sp,
        ),
        style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
        dropdownColor: Colors.white,
        decoration: _floatingLabelDecoration(
          label: 'Department (optional)',
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
            final display = code.isNotEmpty ? '$name ($code)' : name;
            return DropdownMenuItem<int?>(
              value: id,
              child: Text(
                display,
                style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
              ),
            );
          }),
        ],
        onChanged: (v) => controller.selectedDepartmentId.value = v,
      ),
    );
  }

  // ───────────────────────── CREATE BUTTON ─────────────────────────

  Widget _buildCreateButton() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.40),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              controller.createUser();
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  AppText.createUser,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── DECORATIONS / HELPERS ─────────────────────

  InputDecoration _floatingLabelDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
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
      fillColor: _surface,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
      hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: _ink300),
      border: _border(BorderSide(color: _ink200)),
      enabledBorder: _border(BorderSide(color: _ink200)),
      focusedBorder: _border(BorderSide(color: AppColors.primary, width: 1.8)),
      disabledBorder: _border(BorderSide(color: _ink200)),
      errorBorder: _border(
        const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: _border(
        const BorderSide(color: Color(0xFFEF4444), width: 1.8),
      ),
    );
  }

  OutlineInputBorder _border(BorderSide side) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.r),
    borderSide: side,
  );

  Widget _entranceWrap({required Widget child, required Duration duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, t, c) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: c),
        );
      },
      child: child,
    );
  }
}
