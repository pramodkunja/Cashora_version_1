import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/payment_flow_controller.dart';

class PaymentRequestDetailsView extends GetView<PaymentFlowController> {
  const PaymentRequestDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get request data from arguments or controller
    // Get request data from arguments or controller
    final Map<String, dynamic> request = controller.currentRequest.isNotEmpty
        ? controller.currentRequest
        : (Get.arguments is Map ? (Get.arguments['request'] ?? {}) : {});
    final requestor = request['requestor'] ?? {};
    final approver = request['approver'] ?? {};

    final String amount = '₹${request['amount']?.toString() ?? '0.00'}';
    final String requestId =
        request['request_id'] ??
        (request['id'] != null ? '#REQ-${request['id']}' : '');
    final String date = _formatDate(request['created_at']);
    final String purpose = request['purpose'] ?? 'N/A';
    final String description = request['description'] ?? 'No Description';
    final String requestorName =
        "${requestor['first_name'] ?? ''} ${requestor['last_name'] ?? ''}"
            .trim();
    final String requestorRole = requestor['role'] ?? 'Requestor';

    // Receipt/Bill - Try multiple possible backend keys for robustness
    final String? receiptUrl =
        request['receipt_url'] ??
        request['bill_url'] ??
        ((request['bill_urls'] is List &&
                (request['bill_urls'] as List).isNotEmpty)
            ? (request['bill_urls'] as List).first
            : null);
    final String? qrUrl = request['payment_qr_url'] ?? request['qr_url'];
    final String? paymentNote = request['payment_note'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // ... (keep existing AppBar) ...
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Request Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Text(
              'Requested Amount',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              amount,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),

            // Status Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    (request['status']?.toString().toUpperCase() ?? 'APPROVED'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    (request['payment_status']
                            ?.toString()
                            .replaceAll('_', ' ')
                            .toUpperCase() ??
                        'PENDING'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warningOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),
            _buildRequesterCard(
              context,
              requestorName,
              requestorRole,
              requestId,
              date,
              purpose,
              description,
            ),
            SizedBox(height: 16.h),
            SizedBox(height: 16.h),
            _buildBillAttachmentCard(context, receiptUrl, qrUrl),
            if (paymentNote != null && paymentNote.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _buildNoteCard(context, paymentNote),
            ],
            SizedBox(height: 80.h), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildNoteCard(BuildContext context, String note) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_outlined, color: AppColors.textSlate, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Payment Note',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: AppColors.textSlate,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Obx(() {
      final isCompleted =
          (controller.currentRequest['payment_status']?.toString() ?? '') ==
          'completed';

      if (isCompleted) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.markAsPaid(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Mark as Paid',
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildRequesterCard(
    BuildContext context,
    String name,
    String role,
    String id,
    String date,
    String purpose,
    String description,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Unknown User',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      role.capitalizeFirst ?? 'Requestor',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSlate,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(height: 1.h),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(context, 'REQUEST ID', id),
              _buildInfoItem(context, 'DATE', date),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoItem(context, 'PURPOSE', purpose),
          SizedBox(height: 20.h),
          Text(
            'DESCRIPTION',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSlate,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSlate,
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBillAttachmentCard(
    BuildContext context,
    String? billUrl,
    String? qrUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, color: AppColors.textSlate, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Bill & Attachments',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              if (billUrl != null)
                Expanded(
                  child: _buildAttachmentButton(
                    context,
                    'View Bill',
                    Icons.receipt_long_rounded,
                    AppColors.primaryBlue,
                    () {
                      controller.prepareForView(
                        url: billUrl,
                        title: 'Bill Details',
                        isQr: false,
                      );
                      Get.toNamed(
                        AppRoutes.ACCOUNTANT_PAYMENT_BILL_DETAILS,
                        arguments: {
                          'url': billUrl,
                          'title': 'Bill Details',
                          'isQr': false,
                          'request': controller.currentRequest.value,
                        },
                      );
                    },
                  ),
                ),
              if (billUrl != null && qrUrl != null) SizedBox(width: 12.w),
              if (qrUrl != null)
                Expanded(
                  child: _buildAttachmentButton(
                    context,
                    'View QR',
                    Icons.qr_code_2_rounded,
                    AppColors.warningOrange,
                    () {
                      controller.prepareForView(
                        url: qrUrl,
                        title: 'Payment QR',
                        isQr: true,
                      );
                      Get.toNamed(
                        AppRoutes.ACCOUNTANT_PAYMENT_BILL_DETAILS,
                        arguments: {
                          'url': qrUrl,
                          'title': 'Payment QR',
                          'isQr': true,
                          'request': controller.currentRequest.value,
                        },
                      );
                    },
                  ),
                ),
              if (billUrl == null && qrUrl == null)
                Expanded(
                  child: Text(
                    'No attachments provided',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSlate,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
