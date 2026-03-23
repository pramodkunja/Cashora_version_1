import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../controllers/payment_flow_controller.dart';

class MarkAsPaidView extends GetView<PaymentFlowController> {
  const MarkAsPaidView({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh methods on entry if empty
    if (controller.paymentMethods.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchPaymentMethods();
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mark as Paid'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Request Info",
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(() => Text(
                        "Amount: ₹${controller.currentRequest['amount'] ?? '0'}",
                        style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w600),
                      )),
                  SizedBox(height: 4.h),
                  Obx(() => Text(
                        "Expense ID: ${controller.currentRequest['id'] ?? 'N/A'}",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                      )),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Payment Method Dropdown
            Text(
              "Payment Method",
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              if (controller.paymentMethods.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedPaidMethod.value,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textSlate),
                    items: controller.paymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method['value'],
                        child: Text(
                          method['label'] ?? method['value'],
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedPaidMethod.value = newValue;
                      }
                    },
                  ),
                ),
              );
            }),
            SizedBox(height: 24.h),

            // Transaction Reference
            Text(
              "Transaction Reference (Optional)",
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.transactionRefController,
              decoration: InputDecoration(
                hintText: "Enter UTR, Txn ID, etc.",
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 24.h),

            // Payment Note
            Text(
              "Payment Note (Optional)",
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.paymentNoteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "E.g., Paid via GPay...",
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 48.h),

            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.markAsPaid(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            "Confirm Payment",
                            style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
