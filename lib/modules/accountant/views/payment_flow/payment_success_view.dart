import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/payment_flow_controller.dart';

class PaymentSuccessView extends GetView<PaymentFlowController> {
  const PaymentSuccessView({super.key});


  @override
  Widget build(BuildContext context) {
    final amount = (Get.arguments?['amount'] as num?)?.toDouble() ?? 0.0;
    final txnId = Get.arguments?['txnId']?.toString() ?? 'N/A';
    final utr = Get.arguments?['utr']?.toString();
    final dateStr = Get.arguments?['date']?.toString();
    final paymentSource =
        Get.arguments?['paymentSource']?.toString() ?? 'Bank Transfer';
    final payee = Get.arguments?['payee']?.toString() ?? 'Unknown';

    String displayDate = 'Unknown Date';
    if (dateStr != null) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        displayDate =
            '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => controller.backToDashboard(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8.r,
                        ),
                      ],
                    ),
                    child: Icon(Icons.close_rounded,
                        color: AppColors.textDark, size: 20.sp),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Success icon
              Container(
                width: 110.w,
                height: 110.w,
                decoration: BoxDecoration(
                  color: AppColors.mintBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.successGreen.withValues(alpha: 0.2),
                      blurRadius: 30.r,
                      spreadRadius: 4.r,
                    ),
                  ],
                ),
                child: Icon(Icons.check_rounded, color: AppColors.successGreen, size: 60.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                AppText.success,
                style: GoogleFonts.inter(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                AppText.fundsTransferred,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.textSlate,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 28.h),

              // Receipt card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(22.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL PAID',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSlate,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
                    SizedBox(height: 16.h),

                    _row(AppText.transactionId, txnId,
                        trailing: Icon(Icons.copy_rounded,
                            size: 14.sp, color: AppColors.textSlate)),
                    if (utr != null && utr != 'N/A')
                      Padding(
                        padding: EdgeInsets.only(top: 14.h),
                        child: _row('UTR Number', utr,
                            trailing: Icon(Icons.copy_rounded,
                                size: 14.sp, color: AppColors.textSlate)),
                      ),
                    SizedBox(height: 14.h),
                    _row(AppText.paymentDate, displayDate),
                    SizedBox(height: 14.h),
                    _row(
                      AppText.paymentSource,
                      paymentSource,
                      valueColor: AppColors.successGreen,
                      isStatus: true,
                    ),
                    SizedBox(height: 14.h),
                    _rowWithAvatar(AppText.recipient, payee),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(
                      AppRoutes.ACCOUNTANT_PAYMENT_COMPLETED_DETAILS),
                  icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
                  label: Text(
                    AppText.viewRequestDetails,
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
              SizedBox(height: 10.h),
              TextButton(
                onPressed: () => controller.backToDashboard(),
                child: Text(
                  AppText.backToDashboard,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSlate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value,
      {Widget? trailing, Color? valueColor, bool isStatus = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSlate,
            ),
          ),
        ),
        if (isStatus) ...[
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: valueColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
        ],
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 6.w), trailing],
      ],
    );
  }

  Widget _rowWithAvatar(String label, String name) {
    final initials = _initials(name);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSlate,
            ),
          ),
        ),
        CircleAvatar(
          radius: 12.r,
          backgroundColor: AppColors.purpleSurface,
          child: Text(
            initials,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
