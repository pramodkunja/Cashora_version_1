import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../controllers/organization_setup_controller.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';

class OrganizationSetupView extends StatefulWidget {
  const OrganizationSetupView({Key? key}) : super(key: key);

  @override
  State<OrganizationSetupView> createState() => _OrganizationSetupViewState();
}

class _OrganizationSetupViewState extends State<OrganizationSetupView> {
  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);

  OrganizationSetupController get controller =>
      Get.find<OrganizationSetupController>();

  // Phone field state
  int _phoneDigits = 0;
  int _phoneMaxDigits = 10; // Default for IN (India)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Organization Details Card ─────────────────
                    _buildSectionCard(
                      icon: Icons.business_rounded,
                      title: AppText.organizationDetails,
                      children: [
                        _buildLabel(AppText.organizationName),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: controller.orgNameController,
                          hint: AppText.hintOrgName,
                          icon: Icons.apartment_rounded,
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // ── Admin Details Card ────────────────────────
                    _buildSectionCard(
                      icon: Icons.admin_panel_settings_rounded,
                      title: AppText.adminDetails,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('First Name'),
                                  SizedBox(height: 8.h),
                                  _buildTextField(
                                    controller: controller.firstNameController,
                                    hint: 'First Name',
                                    icon: Icons.person_rounded,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Last Name'),
                                  SizedBox(height: 8.h),
                                  _buildTextField(
                                    controller: controller.lastNameController,
                                    hint: 'Last Name',
                                    icon: Icons.person_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        _buildLabel(AppText.workEmail),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: controller.emailController,
                          hint: AppText.hintAdminEmail,
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 18.h),
                        _buildLabel('Phone Number'),
                        SizedBox(height: 8.h),
                        _buildPhoneField(context),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // ── Info Banner ───────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: _purpleLight,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: _purple, size: 20.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              AppText.adminCredentialsInfo,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: _purple,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Secure SSL Indicator ──────────────────────
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded,
                              color: _slate300, size: 13.sp),
                          SizedBox(width: 6.w),
                          Text(
                            AppText.secureSSL,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: _slate500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // ── Create Button ─────────────────────────────
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : controller.createOrganization,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _purple.withOpacity(0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: controller.isLoading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  AppText.createOrganizationAction,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 12.h,
        20.w,
        28.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white, size: 20.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppText.setupOrganization,
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Hero illustration/info
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.corporate_fare_rounded,
                color: Colors.white, size: 32.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            'Let\'s set up your workspace',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Create your organization in a few simple steps',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // SECTION CARD — wraps each group with icon + title header
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: _purple, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _slate900,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          ...children,
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // LABEL
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: _slate500,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // TEXT FIELD
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 14.sp, color: _slate900),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: _slate300,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: _slate500, size: 18.sp)
              : null,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // PHONE FIELD — digits only with live counter
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildPhoneField(BuildContext context) {
    final isComplete = _phoneDigits == _phoneMaxDigits;
    final hasInput = _phoneDigits > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasInput && !isComplete
                  ? AppColors.warningOrange.withOpacity(0.5)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: IntlPhoneField(
            style: GoogleFonts.inter(fontSize: 14.sp, color: _slate900),
            dropdownTextStyle:
                GoogleFonts.inter(fontSize: 14.sp, color: _slate900),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            disableLengthCheck: false,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              hintStyle:
                  GoogleFonts.inter(fontSize: 14.sp, color: _slate300),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              counterText: '', // hide default material counter
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
            initialCountryCode: 'IN',
            onChanged: (phone) {
              final digits = phone.number;
              setState(() {
                _phoneDigits = digits.length;
              });
              controller.fullPhoneNumber.value = phone.completeNumber;
              controller.isPhoneValid.value =
                  digits.length == _phoneMaxDigits;
            },
            onCountryChanged: (country) {
              setState(() {
                // Country maxLength sets the expected digit count
                _phoneMaxDigits = country.maxLength;
                _phoneDigits = 0;
              });
              controller.isPhoneValid.value = false;
            },
          ),
        ),
        SizedBox(height: 6.h),
        // ── Counter / helper text ─────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Icon(
                isComplete
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                size: 13.sp,
                color: isComplete
                    ? AppColors.successGreen
                    : (hasInput ? AppColors.warningOrange : _slate500),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  isComplete
                      ? 'Valid phone number'
                      : 'Enter $_phoneMaxDigits digits',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isComplete
                        ? AppColors.successGreen
                        : (hasInput
                            ? AppColors.warningOrange
                            : _slate500),
                  ),
                ),
              ),
              Text(
                '$_phoneDigits/$_phoneMaxDigits',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isComplete
                      ? AppColors.successGreen
                      : _slate500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
