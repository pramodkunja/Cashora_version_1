import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/widgets/app_gradient_header.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/payment_flow_controller.dart';

class MarkAsPaidView extends GetView<PaymentFlowController> {
  const MarkAsPaidView({super.key});


  @override
  Widget build(BuildContext context) {
    if (controller.paymentMethods.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchPaymentMethods();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          AppGradientHeader(title: 'Mark as Paid'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(22.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B55CE), Color(0xFF8B74E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          blurRadius: 20.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'REQUEST AMOUNT',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(
                          () => Text(
                            '₹${controller.currentRequest['amount'] ?? '0'}',
                            style: GoogleFonts.inter(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(
                          () => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'ID: ${controller.currentRequest['id'] ?? 'N/A'}',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Payment Method Card
                  _buildCard(
                    icon: Icons.payment_rounded,
                    title: 'Payment Method',
                    child: Obx(() {
                      if (controller.paymentMethods.isEmpty) {
                        return SkeletonBlock(height: 48.h, radius: 12.r);
                      }
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: controller.selectedPaidMethod.value,
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSlate, size: 22.sp),
                            style: GoogleFonts.inter(
                                fontSize: 14.sp, color: AppColors.textDark),
                            dropdownColor: Colors.white,
                            items: controller.paymentMethods.map((m) {
                              return DropdownMenuItem<String>(
                                value: m['value'],
                                child: Text(m['label'] ?? m['value']),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) controller.selectedPaidMethod.value = v;
                            },
                          ),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 14.h),

                  // Transaction Reference
                  _buildCard(
                    icon: Icons.tag_rounded,
                    title: 'Transaction Reference (Optional)',
                    child: _textField(
                      controller: controller.transactionRefController,
                      hint: 'Enter UTR, Txn ID, etc.',
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Payment Note
                  _buildCard(
                    icon: Icons.edit_note_rounded,
                    title: 'Payment Note (Optional)',
                    child: _textField(
                      controller: controller.paymentNoteController,
                      hint: 'E.g., Paid via GPay...',
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.markAsPaid(),
              icon: controller.isLoading.value
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.check_circle_rounded, size: 18.sp),
              label: Text(
                'Confirm Payment',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.slate300),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        ),
      ),
    );
  }
}
