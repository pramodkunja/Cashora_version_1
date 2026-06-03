import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/admin_user_controller.dart';

/// Admin → Edit User. Lavender-theme variant matching departments,
/// add-user, and user-list pages.
class AdminEditUserView extends GetView<AdminUserController> {
  const AdminEditUserView({super.key});

  // ── Palette (matches departments + add-user + user-list) ──────────────
  static const Color _bgA = Color(0xFFF0E9FF);
  static const Color _bgB = Color(0xFFF8F7FF);
  static const Color _bgC = Color(0xFFEEF2FF);

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink200 = Color(0xFFE2E8F0);

  static const Color _green = AppColors.successGreen;
  static const Color _greenBg = Color(0xFFECFDF5);
  static const Color _red = AppColors.errorRed;
  static const Color _redBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _bgB,
      resizeToAvoidBottomInset: true,
      body: Obx(() {
        final user = Map<String, dynamic>.from(controller.rxSelectedUser);
        if (user.isEmpty) {
          return Stack(
            children: [
              _backgroundLayer(),
              SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    _buildTopBar(),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: const SkeletonListView(itemCount: 5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        String name =
            (user['full_name'] ??
                    user['name'] ??
                    '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}')
                .toString()
                .trim();
        if (name.isEmpty) name = 'Unknown User';
        final email = (user['email'] ?? '').toString();
        final isActive = user['isActive'] ?? user['is_active'] ?? true;

        return Stack(
          children: [
            _backgroundLayer(),
            SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  _buildTopBar(),
                  _buildHeroBlock(name: name, email: email, isActive: isActive),
                  Expanded(child: _buildFormSheet(bottomInset, isActive)),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─────────────────── BACKGROUND ───────────────────

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
          child: _bloom(280.w, AppColors.primary, 0.18),
        ),
        Positioned(
          top: 40.h,
          left: -60.w,
          child: _bloom(200.w, AppColors.primaryLight, 0.24),
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

  // ─────────────────── TOP BAR ───────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          _circleIconButton(Icons.arrow_back_rounded, () => Get.back()),
          Expanded(
            child: Center(
              child: Text(
                AppText.editUser,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink900,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(icon, color: _ink700, size: 20.sp),
        ),
      ),
    );
  }

  // ─────────────────── HERO BLOCK ───────────────────

  Widget _buildHeroBlock({
    required String name,
    required String email,
    required bool isActive,
  }) {
    final Color avatarAccent = isActive
        ? AppColors.primary
        : AppColors.warningOrange;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 20.h),
      child: Column(
        children: [
          // Gradient avatar badge with accent ring
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: avatarAccent.withValues(alpha: 0.22),
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
                  colors: isActive
                      ? [AppColors.primary, AppColors.primaryLight]
                      : [
                          AppColors.warningOrange,
                          AppColors.warningOrange.withValues(alpha: 0.75),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: avatarAccent.withValues(alpha: 0.35),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initialsOf(name),
                  style: GoogleFonts.outfit(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: _ink900,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 6.h),
          // Email + status pill
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              if (email.isNotEmpty)
                Text(
                  email,
                  style: GoogleFonts.inter(fontSize: 12.sp, color: _ink500),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? _green.withValues(alpha: 0.12)
                      : AppColors.warningOrange.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? Icons.check_circle_rounded
                          : Icons.block_rounded,
                      color: isActive ? _green : AppColors.warningOrange,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: isActive ? _green : AppColors.warningOrange,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────── FORM SHEET ───────────────────

  Widget _buildFormSheet(double bottomInset, bool isActive) {
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

  // ─────────────────── HELPERS ───────────────────

  String _initialsOf(String name) {
    if (name.isEmpty) return '?';
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
