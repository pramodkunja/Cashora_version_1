import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../controllers/payment_flow_controller.dart';

class PaymentSuccessView extends GetView<PaymentFlowController> {
  const PaymentSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0.w),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.backToDashboard(),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 20.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Icon(Icons.check, color: Colors.green, size: 40.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                AppText.success,
                style: AppTextStyles.h1.copyWith(fontSize: 28.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                AppText.fundsTransferred,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSlate,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Text(
                      AppText.totalPaid,
                      style: AppTextStyles.bodySmall.copyWith(
                        letterSpacing: 1.0,
                        color: AppColors.textSlate,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '₹${Get.arguments?['amount']?.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    const Divider(),
                    SizedBox(height: 24.h),
                    _buildReceiptRow(
                      AppText.transactionId,
                      '${Get.arguments?['txnId'] ?? 'N/A'}',
                      icon: Icons.copy,
                    ),
                    SizedBox(height: 16.h),
                    if ((Get.arguments?['utr'] ?? 'N/A') != 'N/A')
                      _buildReceiptRow(
                        'UTR Number',
                        '${Get.arguments?['utr']}',
                        icon: Icons.copy,
                      ),
                    if ((Get.arguments?['utr'] ?? 'N/A') != 'N/A')
                      SizedBox(height: 16.h),
                    Builder(
                      builder: (context) {
                        final dateStr = Get.arguments?['date']?.toString();
                        String displayDate = 'Unknown Date';
                        if (dateStr != null) {
                          try {
                            final dt = DateTime.parse(dateStr).toLocal();
                            displayDate =
                                "${dt.day}/${dt.month}/${dt.year}\n${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                          } catch (_) {}
                        }
                        return _buildReceiptRow(
                          AppText.paymentDate,
                          displayDate,
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildReceiptRow(
                      AppText.paymentSource,
                      '${Get.arguments?['paymentSource'] ?? 'Bank Transfer'}',
                      isStatus: true,
                      statusColor: Colors.green,
                    ),
                    SizedBox(height: 16.h),
                    _buildReceiptRow(
                      AppText.recipient,
                      '${Get.arguments?['payee'] ?? 'Unknown'}',
                      useLocalAvatar: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h), // Replaces Spacer

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.ACCOUNTANT_PAYMENT_COMPLETED_DETAILS);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppText.viewRequestDetails,
                        style: AppTextStyles.buttonText.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => controller.backToDashboard(),
                child: Text(
                  AppText.backToDashboard,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    IconData? icon,
    bool isStatus = false,
    Color? statusColor,
    bool useLocalAvatar = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSlate),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isStatus) ...[
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              if (useLocalAvatar) ...[
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text(
                    'SJ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value.split('\n')[0],
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (value.contains('\n'))
                      Text(
                        value.split('\n')[1],
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSlate,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (icon != null) ...[
                SizedBox(width: 8.w),
                Icon(icon, size: 16.sp, color: AppColors.textSlate),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
