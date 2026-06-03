import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/widgets/app_gradient_header.dart';
import '../../../../utils/app_text.dart';

class PaymentFailedView extends StatelessWidget {
  const PaymentFailedView({super.key});


  @override
  Widget build(BuildContext context) {
    final txnId = Get.arguments?['txnId']?.toString() ?? 'N/A';
    final dateStr = Get.arguments?['date']?.toString();
    final payee = Get.arguments?['payee']?.toString() ?? 'Unknown';
    final error = Get.arguments?['error']?.toString();
    final amount = (Get.arguments?['amount'] as num?)?.toDouble() ?? 0.0;

    String displayDate = 'Unknown Date';
    if (dateStr != null) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        displayDate = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          AppGradientHeader(title: AppText.paymentStatus),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                children: [
                  // Failed icon
                  Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      color: AppColors.redBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.errorRed.withValues(alpha: 0.2),
                          blurRadius: 30.r,
                          spreadRadius: 4.r,
                        ),
                      ],
                    ),
                    child: Icon(Icons.error_outline_rounded,
                        color: AppColors.errorRed, size: 60.sp),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    AppText.paymentFailed,
                    style: GoogleFonts.inter(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    AppText.paymentFailedDesc,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppColors.textSlate,
                      height: 1.5,
                    ),
                  ),

                  // Error details
                  if (error != null) ...[
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.redBg,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: AppColors.errorRed, size: 18.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Error Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.errorRed,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  error,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: AppColors.errorRed.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Transaction details
                  Container(
                    width: double.infinity,
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
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.purpleSurface,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(Icons.receipt_long_rounded,
                                    color: AppColors.primary, size: 16.sp),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                AppText.transactionDetails,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 0, color: const Color(0xFFF1F5F9)),
                        _detailRow(AppText.transactionId, txnId, showCopy: true),
                        Divider(
                            height: 0,
                            indent: 16.w,
                            endIndent: 16.w,
                            color: const Color(0xFFF1F5F9)),
                        _detailRow(AppText.date, displayDate),
                        Divider(
                            height: 0,
                            indent: 16.w,
                            endIndent: 16.w,
                            color: const Color(0xFFF1F5F9)),
                        _detailRow(AppText.recipient, payee, isPayee: true),
                        Divider(
                            height: 0,
                            indent: 16.w,
                            endIndent: 16.w,
                            color: const Color(0xFFF1F5F9)),
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppText.totalAmount,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: AppColors.textSlate,
                                ),
                              ),
                              Text(
                                '₹${amount.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28.h),

                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.refresh_rounded, size: 18.sp),
                      label: Text(
                        AppText.retryPayment,
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
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        AppText.goBackToDetails,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.headset_mic_outlined,
                          size: 14.sp, color: AppColors.textSlate),
                      SizedBox(width: 6.w),
                      Text(
                        AppText.needHelpContactSupport,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textSlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool showCopy = false, bool isPayee = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
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
          if (isPayee) ...[
            CircleAvatar(
              radius: 10.r,
              backgroundColor: AppColors.purpleSurface,
              child: Text(
                _initials(value),
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 6.w),
          ],
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showCopy) ...[
            SizedBox(width: 6.w),
            Icon(Icons.copy_rounded, size: 14.sp, color: AppColors.textSlate),
          ],
        ],
      ),
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
