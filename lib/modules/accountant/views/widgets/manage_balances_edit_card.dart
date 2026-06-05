import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import '../../controllers/manage_balances_controller.dart';

/// Edit form card for updating opening / closing balance and an optional note.
class ManageBalancesEditCard extends StatelessWidget {
  const ManageBalancesEditCard({super.key, required this.controller});

  final ManageBalancesController controller;

  static const _slate600 = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField(
            label: 'Opening balance',
            controller: controller.openingController,
            prefix: '₹',
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            required: true,
          ),
          SizedBox(height: 12.h),
          _textField(
            label: 'Closing balance (optional)',
            controller: controller.closingController,
            prefix: '₹',
            keyboard: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 12.h),
          _textField(
            label: 'Note (optional)',
            controller: controller.noteController,
            hint: 'e.g. cash deposit from main vault',
            keyboard: TextInputType.text,
            maxLines: 2,
          ),
          SizedBox(height: 16.h),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed:
                    controller.isSaving.value ? null : controller.saveBalance,
                icon: controller.isSaving.value
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.save_rounded, size: 18.sp),
                label: Text(
                  controller.isSaving.value ? 'Saving…' : 'Save changes',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? prefix,
    TextInputType? keyboard,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _slate600,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.errorRed,
                ),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
            decoration: InputDecoration(
              prefixText: prefix,
              prefixStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSlate,
                fontWeight: FontWeight.w600,
              ),
              hintText: hint,
              hintStyle:
                  GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textSlate),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12.r,
          offset: Offset(0, 3.h),
        ),
      ],
    );
  }
}
