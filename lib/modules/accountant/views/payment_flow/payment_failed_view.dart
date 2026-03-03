import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';

class PaymentFailedView extends StatelessWidget {
  const PaymentFailedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(AppText.paymentStatus, style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60.sp,
                color: AppColors.errorRed,
              ),
            ),
            SizedBox(height: 24.h),
            Text(AppText.paymentFailed, style: AppTextStyles.h1),
            SizedBox(height: 12.h),
            Text(
              AppText.paymentFailedDesc,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSlate,
              ),
            ),
            SizedBox(height: 24.h),
            // Error Message Display
            if (Get.arguments?['error'] != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.errorRed.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.errorRed,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error Details',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.errorRed,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${Get.arguments?['error']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.errorRed.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 40.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200] ?? Colors.grey.shade200),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.textSlate,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          AppText.transactionDetails,
                          style: AppTextStyles.bodySmall.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1.h, color: Colors.grey[200]),
                  _buildDetailRow(
                    AppText.transactionId,
                    '${Get.arguments?['txnId'] ?? 'N/A'}',
                    showCopy: true,
                  ),
                  Divider(height: 1.h, color: Colors.grey[200]),
                  Builder(
                    builder: (context) {
                      final dateStr = Get.arguments?['date']?.toString();
                      String displayDate = 'Unknown Date';
                      if (dateStr != null) {
                        try {
                          final dt = DateTime.parse(dateStr).toLocal();
                          displayDate = "${dt.day}/${dt.month}/${dt.year}";
                        } catch (_) {}
                      }
                      return _buildDetailRow(AppText.date, displayDate);
                    },
                  ),
                  Divider(height: 1.h, color: Colors.grey[200]),
                  _buildDetailRow(
                    AppText.recipient,
                    '${Get.arguments?['payee'] ?? 'Unknown'}',
                    isRecipient: true,
                  ),
                  Divider(height: 1.h, color: Colors.grey[200]),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppText.totalAmount,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSlate,
                          ),
                        ),
                        Text(
                          '₹${Get.arguments?['amount']?.toStringAsFixed(2) ?? '0.00'}',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(), // Retry Logic could be here
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppText.retryPayment,
                  style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(), // Go back Logic
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.backgroundLight,
                  side: BorderSide.none,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  AppText.goBackToDetails,
                  style: AppTextStyles.buttonText.copyWith(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.headset_mic_outlined,
                  size: 16.sp,
                  color: AppColors.textSlate,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppText.needHelpContactSupport,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSlate,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool showCopy = false,
    bool isRecipient = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSlate,
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            // Use Flexible to allow shrinking
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end, // Align right
              children: [
                if (isRecipient) ...[
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'JD',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  // Nested Flexible for text
                  child: Text(
                    value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showCopy) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.copy_rounded,
                    size: 16.sp,
                    color: AppColors.textSlate,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
