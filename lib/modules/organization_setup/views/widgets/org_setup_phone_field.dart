import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../controllers/organization_setup_controller.dart';
import '../../../../utils/app_colors.dart';

class OrgSetupPhoneField extends StatefulWidget {
  const OrgSetupPhoneField({super.key, required this.controller});

  final OrganizationSetupController controller;

  @override
  State<OrgSetupPhoneField> createState() => _OrgSetupPhoneFieldState();
}

class _OrgSetupPhoneFieldState extends State<OrgSetupPhoneField> {
  int _phoneDigits = 0;
  int _phoneMaxDigits = 10; // Default for IN (India)

  @override
  Widget build(BuildContext context) {
    final isComplete = _phoneDigits == _phoneMaxDigits;
    final hasInput = _phoneDigits > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasInput && !isComplete
                  ? AppColors.warningOrange.withValues(alpha: 0.5)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: IntlPhoneField(
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
            dropdownTextStyle:
                GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            disableLengthCheck: false,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              hintStyle:
                  GoogleFonts.inter(fontSize: 14.sp, color: AppColors.slate300),
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
              widget.controller.fullPhoneNumber.value = phone.completeNumber;
              widget.controller.isPhoneValid.value =
                  digits.length == _phoneMaxDigits;
            },
            onCountryChanged: (country) {
              setState(() {
                // Country maxLength sets the expected digit count
                _phoneMaxDigits = country.maxLength;
                _phoneDigits = 0;
              });
              widget.controller.isPhoneValid.value = false;
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
                    : (hasInput ? AppColors.warningOrange : AppColors.textSlate),
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
                            : AppColors.textSlate),
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
                      : AppColors.textSlate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
