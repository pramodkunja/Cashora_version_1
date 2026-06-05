import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/widgets/app_gradient_header.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/payment_flow_controller.dart';
import 'widgets/confirm_payment_amount_card.dart';
import 'widgets/confirm_payment_bottom_bar.dart';
import 'widgets/confirm_payment_details_form.dart';
import 'widgets/confirm_payment_method_selector.dart';
import 'widgets/confirm_payment_primitives.dart';

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
                    ConfirmPaymentAmountCard(
                      amount: controller.finalAmount.value,
                    ),
                    SizedBox(height: 20.h),
                    Obx(
                      () => ConfirmPaymentMethodSelector(
                        selectedMethod:
                            controller.selectedPaymentMethod.value,
                        onMethodChanged: (v) =>
                            controller.selectedPaymentMethod.value = v,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Obx(
                      () => ConfirmPaymentDetailsForm(
                        selectedMethod:
                            controller.selectedPaymentMethod.value,
                        vpaController: controller.vpaController,
                        accountHolderController:
                            controller.accountHolderController,
                        accountNumberController:
                            controller.accountNumberController,
                        ifscController: controller.ifscController,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    ConfirmPaymentSectionCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Remarks (Optional)',
                      child: ConfirmPaymentField(
                        controller: controller.remarksController,
                        hint: 'Add payment remarks',
                        icon: Icons.note_rounded,
                        maxLength: 50,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _InfoBanner(),
                  ],
                ),
              ),
            ),
            ConfirmPaymentBottomBar(
              onInitiate: () => controller.initiatePayment(),
            ),
          ],
        );
      }),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
