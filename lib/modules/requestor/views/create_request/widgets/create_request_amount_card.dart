import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/app_colors.dart';
import '../../../controllers/create_request_controller.dart';
import 'create_request_primitives.dart';

/// Amount section card — big numeric input with a ₹ prefix, plus a
/// dynamic limit-status pill ("Approval required" / "Within limit").
class CreateRequestAmountCard extends StatelessWidget {
  final CreateRequestController controller;
  const CreateRequestAmountCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CreateRequestSectionCard(
      icon: Icons.currency_rupee_rounded,
      title: 'Amount',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: GoogleFonts.inter(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate300,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 8.w),
                  child: Text(
                    '₹',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSlate,
                    ),
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 16.h,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            if (controller.amount.value <= 0) {
              return const SizedBox.shrink();
            }
            final needsApproval =
                controller.category.value == 'Approval Required';
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: needsApproval
                    ? AppColors.amberBg
                    : AppColors.mintBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    needsApproval
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_rounded,
                    color: needsApproval
                        ? AppColors.warningOrange
                        : AppColors.successGreen,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      needsApproval
                          ? 'Approval required • exceeds limit'
                          : 'Within limit • auto-approved',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: needsApproval
                            ? AppColors.warningOrange
                            : AppColors.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
