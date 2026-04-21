import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/payment_flow_controller.dart';

class PaymentRequestDetailsView extends GetView<PaymentFlowController> {
  const PaymentRequestDetailsView({super.key});

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _amber = AppColors.warningOrange;
  static const _amberBg = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    final request = controller.currentRequest.isNotEmpty
        ? controller.currentRequest
        : (Get.arguments is Map ? (Get.arguments['request'] ?? {}) : {});
    final requestor = request['requestor'] ?? {};

    final amount = (request['amount'] as num?)?.toDouble() ?? 0.0;
    final requestId = request['request_id']?.toString() ??
        (request['id'] != null ? '#REQ-${request['id']}' : '');
    final date = _formatDate(request['created_at']?.toString());
    final purpose = request['purpose']?.toString() ?? 'N/A';
    final description =
        request['description']?.toString() ?? 'No Description';
    final requestorName =
        '${requestor['first_name'] ?? ''} ${requestor['last_name'] ?? ''}'
            .trim();
    final role = requestor['role']?.toString() ?? 'Requestor';

    final receiptUrl = request['receipt_url']?.toString() ??
        request['bill_url']?.toString() ??
        ((request['bill_urls'] is List &&
                (request['bill_urls'] as List).isNotEmpty)
            ? (request['bill_urls'] as List).first.toString()
            : null);
    final qrUrl = request['payment_qr_url']?.toString() ??
        request['qr_url']?.toString();
    final paymentNote = request['payment_note']?.toString();

    final statusLabel =
        (request['status']?.toString() ?? 'approved').toUpperCase();
    final paymentStatus = (request['payment_status']
                ?.toString()
                .replaceAll('_', ' ') ??
            'pending')
        .toUpperCase();

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                children: [
                  // Amount card
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
                          color: _purple.withOpacity(0.22),
                          blurRadius: 20.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'REQUESTED AMOUNT',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.85),
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _headerPill(
                                label: statusLabel,
                                icon: Icons.check_circle_rounded),
                            SizedBox(width: 8.w),
                            _headerPill(
                                label: paymentStatus,
                                icon: Icons.schedule_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Requester Card
                  _buildCard(
                    icon: Icons.person_rounded,
                    title: 'Requester Info',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: _purpleLight,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Center(
                                child: Text(
                                  _initials(requestorName),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _purple,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    requestorName.isNotEmpty
                                        ? requestorName
                                        : 'Unknown User',
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: _slate900,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    role.capitalizeFirst ?? 'Requestor',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: _slate500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            Expanded(
                                child: _infoItem('REQUEST ID', requestId)),
                            Expanded(child: _infoItem('DATE', date)),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        _infoItem('PURPOSE', purpose),
                        SizedBox(height: 14.h),
                        _infoItem('DESCRIPTION', description, multiline: true),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Attachments Card
                  _buildCard(
                    icon: Icons.attach_file_rounded,
                    title: 'Bill & Attachments',
                    child: (receiptUrl == null && qrUrl == null)
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Text(
                              'No attachments provided',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: _slate500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              if (receiptUrl != null)
                                Expanded(
                                  child: _attachmentTile(
                                    icon: Icons.receipt_long_rounded,
                                    label: 'View Bill',
                                    onTap: () {
                                      controller.prepareForView(
                                        url: receiptUrl,
                                        title: 'Bill Details',
                                        isQr: false,
                                      );
                                      Get.toNamed(
                                        AppRoutes
                                            .ACCOUNTANT_PAYMENT_BILL_DETAILS,
                                        arguments: {
                                          'url': receiptUrl,
                                          'title': 'Bill Details',
                                          'isQr': false,
                                          'request':
                                              controller.currentRequest.value,
                                        },
                                      );
                                    },
                                  ),
                                ),
                              if (receiptUrl != null && qrUrl != null)
                                SizedBox(width: 10.w),
                              if (qrUrl != null)
                                Expanded(
                                  child: _attachmentTile(
                                    icon: Icons.qr_code_2_rounded,
                                    label: 'View QR',
                                    onTap: () {
                                      controller.prepareForView(
                                        url: qrUrl,
                                        title: 'Payment QR',
                                        isQr: true,
                                      );
                                      Get.toNamed(
                                        AppRoutes
                                            .ACCOUNTANT_PAYMENT_BILL_DETAILS,
                                        arguments: {
                                          'url': qrUrl,
                                          'title': 'Payment QR',
                                          'isQr': true,
                                          'request':
                                              controller.currentRequest.value,
                                        },
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                  ),

                  if (paymentNote != null && paymentNote.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    _buildCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Payment Note',
                      child: Text(
                        paymentNote,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: _slate900,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _headerPill({required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        22.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Request Details',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Obx(() {
      final isCompleted =
          (controller.currentRequest['payment_status']?.toString() ?? '') ==
              'completed';
      if (isCompleted) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
              onPressed: () => Get.toNamed(
                  AppRoutes.ACCOUNTANT_PAYMENT_MARK_AS_PAID),
              icon: Icon(Icons.check_circle_rounded, size: 18.sp),
              label: Text(
                'Mark as Paid',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
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
    });
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
            color: Colors.black.withOpacity(0.03),
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
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: _purple, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: _slate900,
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

  Widget _infoItem(String label, String value, {bool multiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: _slate500,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _slate900,
            height: multiline ? 1.5 : null,
          ),
          maxLines: multiline ? null : 1,
          overflow: multiline ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _attachmentTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _purpleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _purple, size: 22.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _purple,
              ),
            ),
          ],
        ),
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
