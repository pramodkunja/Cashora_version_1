import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import '../../../../../utils/app_text_styles.dart';
import '../../../controllers/payment_flow_controller.dart';

class BillDetailsQrPopup extends StatelessWidget {
  const BillDetailsQrPopup({super.key, required this.controller});

  final PaymentFlowController controller;

  @override
  Widget build(BuildContext context) {
    final details = controller.scannedDetails;
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFB2EBF2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.paymentDetailsFound,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Verified UPI QR",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                _buildDetailRow(
                  AppText.payeeName,
                  details['pn'] ?? 'Unknown',
                  boldValue: true,
                ),
                Divider(height: 24.h),
                _buildDetailRow(AppText.upiId, details['pa'] ?? 'Unknown', isCopyable: true),
                Divider(height: 24.h),
                if (details['am'] != null && details['am']!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppText.amount,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                        ),
                      ),
                      Text(
                        '₹${details['am']}',
                        style: AppTextStyles.h1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              Get.toNamed('/accountant/payment/confirm');
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1aa3df),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 24.sp,
                              width: 24.sp,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppText.useForPayment,
                                  style: AppTextStyles.buttonText.copyWith(
                                    fontSize: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool boldValue = false, bool isCopyable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                style: boldValue
                    ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)
                    : AppTextStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCopyable) ...[
              SizedBox(width: 8.w),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  Get.snackbar(
                    'Copied',
                    '$label copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.successGreen.withValues(alpha: 0.9),
                    colorText: Colors.white,
                    margin: EdgeInsets.all(16.w),
                  );
                },
                child: Icon(Icons.copy, size: 16.sp, color: AppColors.primaryBlue),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
