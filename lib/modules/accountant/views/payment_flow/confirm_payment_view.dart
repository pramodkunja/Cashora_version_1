import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/widgets/app_gradient_header.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/payment_flow_controller.dart';

class ConfirmPaymentView extends GetView<PaymentFlowController> {
  const ConfirmPaymentView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SkeletonListView();
        }
        return Column(
          children: [
            AppGradientHeader(title: 'Confirm Payment'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Gradient Card
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
                            'PAYMENT AMOUNT',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '₹${controller.finalAmount.value.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 34.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Payment Method Card
                    _buildCard(
                      icon: Icons.payment_rounded,
                      title: 'Select Payment Method',
                      child: Obx(
                        () => Column(
                          children: [
                            _methodTile(
                              title: 'UPI Payment',
                              subtitle: 'Pay using UPI ID',
                              icon: Icons.account_balance_wallet_rounded,
                              value: 'VPA',
                              groupValue:
                                  controller.selectedPaymentMethod.value,
                              onChanged: (v) =>
                                  controller.selectedPaymentMethod.value = v!,
                            ),
                            SizedBox(height: 10.h),
                            _methodTile(
                              title: 'Bank Transfer',
                              subtitle: 'Pay using bank account',
                              icon: Icons.account_balance_rounded,
                              value: 'BANK_ACCOUNT',
                              groupValue:
                                  controller.selectedPaymentMethod.value,
                              onChanged: (v) =>
                                  controller.selectedPaymentMethod.value = v!,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Details form card
                    Obx(() {
                      if (controller.selectedPaymentMethod.value == 'VPA') {
                        return _buildCard(
                          icon: Icons.qr_code_rounded,
                          title: 'UPI Details',
                          child: _field(
                            label: 'UPI ID *',
                            controller: controller.vpaController,
                            hint: 'e.g., user@upi',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        );
                      }
                      return _buildCard(
                        icon: Icons.account_balance_rounded,
                        title: 'Bank Account Details',
                        child: Column(
                          children: [
                            _field(
                              label: 'Account Holder Name *',
                              controller: controller.accountHolderController,
                              hint: 'Enter account holder name',
                              icon: Icons.person_rounded,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                            ),
                            SizedBox(height: 14.h),
                            _field(
                              label: 'Account Number *',
                              controller: controller.accountNumberController,
                              hint: 'Enter account number',
                              icon: Icons.numbers_rounded,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                            SizedBox(height: 14.h),
                            _field(
                              label: 'IFSC Code *',
                              controller: controller.ifscController,
                              hint: 'e.g., SBIN0001234',
                              icon: Icons.code_rounded,
                              textCapitalization:
                                  TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Z0-9]')),
                                LengthLimitingTextInputFormatter(11),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 14.h),

                    // Remarks Card
                    _buildCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Remarks (Optional)',
                      child: _field(
                        controller: controller.remarksController,
                        hint: 'Add payment remarks',
                        icon: Icons.note_rounded,
                        maxLength: 50,
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Info banner
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.purpleSurface,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_rounded,
                              color: AppColors.primary, size: 18.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Payment will be processed securely. You will be notified when complete.',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        );
      }),
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
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: () => controller.initiatePayment(),
            icon: Icon(Icons.send_rounded, size: 18.sp),
            label: Text(
              'Initiate Payment',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _methodTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purpleSurface.withValues(alpha: 0.5) : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.purpleSurface,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textSlate,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.slate300,
                  width: 2.w,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    String? label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSlate,
            ),
          ),
          SizedBox(height: 6.h),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.slate300),
              prefixIcon: Icon(icon, color: AppColors.textSlate, size: 18.sp),
              border: InputBorder.none,
              counterText: '',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }
}
