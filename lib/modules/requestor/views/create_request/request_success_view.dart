import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/create_request_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';

class RequestSuccessView extends GetView<CreateRequestController> {
  const RequestSuccessView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _amber = AppColors.warningOrange;
  static const _amberBg = Color(0xFFFFFBEB);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final status = args['status'] as String? ?? 'pending';
    final paymentStatus = args['payment_status'] as String? ?? 'Pending';
    final amount = (args['amount'] as num?)?.toDouble() ?? 0.0;
    final requestId = args['request_id'] as String? ?? '';
    final categoryName = args['category'] as String? ?? 'General';
    final purpose = args['purpose'] as String? ?? '';
    final description = args['description'] as String? ?? '';
    final date = args['date'] as String? ?? '';
    final attachments = args['attachments'] ?? [];

    final isApproved = status == 'auto_approved';
    final iconColor = isApproved ? _green : _amber;
    final iconBg = isApproved ? _greenBg : _amberBg;
    final mainIcon =
        isApproved ? Icons.check_rounded : Icons.hourglass_top_rounded;
    final title =
        isApproved ? AppText.requestApproved : AppText.requestSubmitted;
    final subtitle =
        isApproved ? AppText.fundsAdded : AppText.requestSubmittedDesc;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutes.REQUESTOR),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8.r,
                          ),
                        ],
                      ),
                      child: Icon(Icons.close_rounded,
                          color: _slate900, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withOpacity(0.2),
                            blurRadius: 30.r,
                            spreadRadius: 3.r,
                          ),
                        ],
                      ),
                      child: Icon(mainIcon, size: 48.sp, color: iconColor),
                    ),
                    SizedBox(height: 24.h),

                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: _slate900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: _slate500,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Summary Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Amount
                          Text(
                            AppText.totalAmount.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: _slate500,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '₹${amount.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w800,
                              color: _slate900,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Divider(
                              height: 1.h, color: const Color(0xFFF1F5F9)),
                          SizedBox(height: 16.h),

                          // Details
                          _infoRow(Icons.inventory_2_rounded,
                              AppText.category, categoryName),
                          SizedBox(height: 14.h),
                          _infoRow(Icons.tag_rounded, AppText.requestId,
                              '#$requestId'),
                          SizedBox(height: 16.h),

                          _statusRow(
                            label: AppText.status,
                            value: isApproved
                                ? AppText.approvedSC
                                : AppText.pendingSC,
                            icon: isApproved
                                ? Icons.check_circle_rounded
                                : Icons.access_time_rounded,
                            color: isApproved ? _green : _amber,
                            bg: isApproved ? _greenBg : _amberBg,
                          ),
                          SizedBox(height: 12.h),
                          _statusRow(
                            label: AppText.paymentStatus,
                            value: paymentStatus,
                            icon: Icons.hourglass_empty_rounded,
                            color: _slate500,
                            bg: const Color(0xFFF1F5F9),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: () =>
                            Get.offAllNamed(AppRoutes.REQUESTOR),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          AppText.goToDashboard,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.REQUEST_DETAILS_READ,
                          arguments: {
                            'title': purpose,
                            'amount': amount,
                            'status': status == 'auto_approved'
                                ? 'Approved'
                                : 'Pending',
                            'category': categoryName,
                            'date': date,
                            'description': description,
                            'attachments': attachments,
                          },
                        );
                      },
                      child: Text(
                        AppText.viewDetails,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _purple,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _purpleLight,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: _purple, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: _slate500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: _slate900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: _slate500,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13.sp, color: color),
              SizedBox(width: 5.w),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
