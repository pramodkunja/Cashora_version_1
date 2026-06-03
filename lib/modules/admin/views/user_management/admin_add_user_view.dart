import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/admin_user_controller.dart';

class AdminAddUserView extends GetView<AdminUserController> {
  const AdminAddUserView({super.key});

  // ── Light palette (matches login/auth language) ───────────────────────
  static const Color _bgA = Color(0xFFF0E9FF);
  static const Color _bgB = Color(0xFFF8F7FF);
  static const Color _bgC = Color(0xFFEEF2FF);

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink300 = Color(0xFFCBD5E1);
  static const Color _ink200 = Color(0xFFE2E8F0);
  static const Color _surface = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bgB,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _backgroundLayer(),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                _buildHeroBlock(),
                Expanded(child: _buildWhiteSheet(formKey, bottomInset)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── BACKGROUND ─────────────────────────

  Widget _backgroundLayer() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgA, _bgB, _bgC],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -90.h,
          right: -70.w,
          child: _bloom(280.w, AppColors.primary, 0.20),
        ),
        Positioned(
          top: 40.h,
          left: -60.w,
          child: _bloom(200.w, AppColors.primaryLight, 0.26),
        ),
      ],
    );
  }

  Widget _bloom(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Get.back(),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Icon(Icons.arrow_back_rounded,
                    color: _ink700, size: 20.sp),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppText.addNewUserTitle,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink900,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          // Symmetry spacer matching the back-button footprint
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  // ───────────────────────── HERO BLOCK ─────────────────────────

  Widget _buildHeroBlock() {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 14.h, 28.w, 22.h),
      child: Column(
        children: [
          _entranceWrap(
            duration: const Duration(milliseconds: 600),
            child: _buildAvatarBadge(),
          ),
          SizedBox(height: 16.h),
          _entranceWrap(
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'NEW USER',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          _entranceWrap(
            duration: const Duration(milliseconds: 900),
            child: Text(
              'Add a team member',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: _ink900,
                letterSpacing: -0.6,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          _entranceWrap(
            duration: const Duration(milliseconds: 1000),
            child: Text(
              'Set up access for a new requestor or accountant.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: _ink500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarBadge() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
          width: 1.4,
        ),
      ),
      child: Container(
        width: 76.w,
        height: 76.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Icon(
          Icons.person_add_alt_1_rounded,
          color: Colors.white,
          size: 36.sp,
        ),
      ),
    );
  }

  // ───────────────────────── WHITE SHEET ─────────────────────────

  Widget _buildWhiteSheet(
      GlobalKey<FormState> formKey, double bottomInset) {
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
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 28.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 24.h + bottomInset),
        child: Form(
          key: formKey,
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
                child: _buildCreateButton(formKey),
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
        value: controller.selectedRole.value.isEmpty
            ? null
            : controller.selectedRole.value,
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: _ink500, size: 22.sp),
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
        validator: (val) =>
            (val == null || val.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Obx(
      () => DropdownButtonFormField<int?>(
        value: controller.selectedDepartmentId.value,
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: _ink500, size: 22.sp),
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
          ...controller.departments
              .where((d) => d['is_active'] == true)
              .map((d) {
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

  Widget _buildCreateButton(GlobalKey<FormState> formKey) {
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
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (formKey.currentState!.validate()) {
              controller.createUser();
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_rounded,
                    color: Colors.white, size: 20.sp),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
      ),
    );
  }

  Widget _entranceWrap({required Widget child, required Duration duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, t, c) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
