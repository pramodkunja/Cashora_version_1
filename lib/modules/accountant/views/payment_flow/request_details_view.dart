import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/request_details_layout.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/payment_flow_controller.dart';

/// Accountant-side expense detail screen. Reuses the shared
/// [RequestDetailsLayout] so the visual design matches the admin's
/// request-details screen exactly. The only role-specific concern is the
/// "Mark as Paid" bottom action, which is hidden once the expense is
/// already completed.
class PaymentRequestDetailsView extends GetView<PaymentFlowController> {
  const PaymentRequestDetailsView({super.key});


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Source of truth: controller's reactive request, with arguments as a
      // fallback for the very first frame before the controller hydrates.
      final fromController = controller.currentRequest;
      final fromArgs = Get.arguments is Map
          ? ((Get.arguments as Map)['request'] ?? Get.arguments) as Map?
          : null;
      final Map<dynamic, dynamic> request =
          (fromController.isNotEmpty ? fromController : (fromArgs ?? {}));

      return RequestDetailsLayout(
        request: request,
        variant: RequestDetailVariant.awaitingPayment,
        headerTitle: 'Request Details',
        bottomBar: _buildMarkAsPaid(request),
      );
    });
  }

  /// "Mark as Paid" CTA. Hidden when the expense is already settled.
  Widget? _buildMarkAsPaid(Map<dynamic, dynamic> request) {
    final paymentStatus =
        (request['payment_status']?.toString() ?? '').toLowerCase();
    if (paymentStatus == 'paid' || paymentStatus == 'completed') {
      return null;
    }
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14.r,
            offset: Offset(0, -3.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.ACCOUNTANT_PAYMENT_MARK_AS_PAID),
            icon: Icon(Icons.check_circle_rounded, size: 18.sp),
            label: Text(
              'Mark as Paid',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
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
}
