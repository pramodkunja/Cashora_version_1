import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../utils/widgets/buttons/secondary_button.dart';
import '../../../../utils/widgets/attachment_card.dart';
import '../controllers/admin_request_details_controller.dart';

class AdminRequestDetailsView extends GetView<AdminRequestDetailsController> {
  const AdminRequestDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).iconTheme.color,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(AppText.requestDetails, style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final status = (controller.request['status'] ?? 'Pending')
              .toString()
              .toLowerCase();

          if (status == 'approved' || status == 'auto_approved') {
            return _buildApprovedUI(context);
          } else if (status == 'rejected') {
            return _buildRejectedUI(context);
          } else {
            return _buildPendingUI(context);
          }
        }),
      ),
    );
  }

  // --- APPROVED UI ---
  Widget _buildApprovedUI(BuildContext context) {
    final req = controller.request;
    final userName = _getUserName(req);
    final department = _getDepartment(req);
    final purpose =
        req['description'] ?? req['purpose'] ?? 'No description provided.';
    final submittedOn = _formatDateShort(req['created_at']?.toString() ?? '');
    final actionDate = _formatDateShort(req['updated_at']?.toString() ?? '');

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Status Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5), // Emerald 100 - Exact match
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF10B981),
                  size: 20.sp,
                ), // Emerald 500
                SizedBox(width: 8.w),
                Text(
                  "APPROVED",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF047857),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ), // Emerald 700
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 2. Amount
          Obx(
            () => Text(
              '₹${req['amount'] ?? '0.00'}',
              style: AppTextStyles.h1.copyWith(
                fontSize: 48.sp,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.displayLarge?.color,
              ), // Slate 900
            ),
          ),
          SizedBox(height: 8.h),

          // 3. Request ID
          Text(
            "REQUEST ID #${req['id'] ?? req['request_id'] ?? '---'}",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSlate,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 32.h),

          // 4. Details Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: const Color(0xFFE0F2FE), // Sky 100
                      child: Text(
                        _getInitials(userName),
                        style: TextStyle(
                          color: const Color(0xFF0369A1),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ), // Sky 700
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            department,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSlate,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Purpose
                Text(
                  "PURPOSE",
                  style: TextStyle(
                    color: AppColors.textSlate,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  purpose,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Divider(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                SizedBox(height: 24.h),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SUBMITTED ON",
                            style: TextStyle(
                              color: AppColors.textSlate,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            submittedOn,
                            style: AppTextStyles.h3.copyWith(fontSize: 15.sp),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ACTION DATE",
                            style: TextStyle(
                              color: AppColors.textSlate,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            actionDate,
                            style: AppTextStyles.h3.copyWith(fontSize: 15.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          _buildAttachmentsSection(context),
          SizedBox(height: 24.h),

          // 6. Timeline Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).iconTheme.color,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Approval Timeline",
                      style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Timeline Items
                ..._buildNewTimelineItems(),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  List<Widget> _buildNewTimelineItems() {
    final history = <Widget>[];
    final req = controller.request;

    // 1. Approved (Top)
    history.add(
      _buildTimelineRow(
        title: "Approved by ${req['approver_name'] ?? 'Approver'}",
        date: _formatDate(req['updated_at']?.toString() ?? ''),
        comment: "Approved as per budget allocation.",
        isCompleted: true,
        showLine: true,
      ),
    );

    // 2. Pending (Middle - Simulated for visual matching)
    history.add(
      _buildTimelineRow(
        title: "Pending Approval",
        date: _formatDate(req['created_at']?.toString() ?? ''),
        isCompleted: false, // Gray dot
        showLine: true,
      ),
    );

    // 3. Submitted (Bottom)
    history.add(
      _buildTimelineRow(
        title: "Request Submitted",
        date: _formatDate(req['created_at']?.toString() ?? ''),
        isCompleted: false,
        showLine: false, // Last item
      ),
    );

    return history;
  }

  Widget _buildTimelineRow({
    required String title,
    required String date,
    String? comment,
    required bool isCompleted,
    required bool showLine,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFF1F5F9), // Emerald 100 vs Slate 100
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF94A3B8),
                size: 12.sp,
              ), // Emerald 500 vs Slate 400
            ),
            if (showLine)
              Container(
                width: 2.w,
                height: 40.h,
                color: const Color(0xFFE2E8F0),
              ), // Slate 200
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h3.copyWith(fontSize: 15.sp)),
              SizedBox(height: 4.h),
              Text(
                date,
                style: TextStyle(color: AppColors.textSlate, fontSize: 13.sp),
              ),
              if (comment != null) ...[
                SizedBox(height: 4.h),
                Text(
                  comment,
                  style: TextStyle(
                    color: AppColors.textSlate,
                    fontStyle: FontStyle.italic,
                    fontSize: 13.sp,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }

  // --- REJECTED UI ---
  Widget _buildRejectedUI(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1), // Light Red
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.block, color: AppColors.error, size: 32.sp),
          ),
          SizedBox(height: 16.h),
          Obx(
            () => Text(
              '₹${controller.request['amount'] ?? '0.00'}',
              style: AppTextStyles.h1.copyWith(fontSize: 40.sp),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              AppText.statusRejected.toUpperCase(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          _buildRejectionReasonCard(context),
          SizedBox(height: 24.h),
          _buildInformationCard(context),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.navHistory,
                style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(children: [..._buildDynamicHistory()]),
          ),
        ],
      ),
    );
  }

  // --- PENDING UI (Existing) ---
  Widget _buildPendingUI(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: _getAvatarColor(
                  _getInitials(_getUserName(controller.request)),
                ),
                child: Text(
                  _getInitials(_getUserName(controller.request)),
                  style: TextStyle(
                    color: _getAvatarTextColor(
                      _getInitials(_getUserName(controller.request)),
                    ),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        _getUserName(controller.request),
                        style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                      ),
                    ),
                    Text(
                      '${controller.request['department'] ?? 'General'} • ${controller.request['created_at'] != null ? _formatDate(controller.request['created_at']) : 'Recently'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSlate,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Detail Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    '₹${controller.request['amount'] ?? '0.00'}',
                    style: AppTextStyles.h1.copyWith(fontSize: 36.sp),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => Text(
                    controller.request['title'] ?? 'Title',
                    style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildInfoRow(
                  Icons.business_center_rounded,
                  AppText.businessMeal,
                ),
                SizedBox(height: 16.h),
                _buildInfoRow(
                  Icons.hourglass_empty_rounded,
                  AppText.pendingApproval,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Description Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.description,
                  style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  controller.request['description'] ??
                      controller.request['purpose'] ??
                      'No description provided.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSlate,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          _buildAttachmentsSection(context),
          SizedBox(height: 24.h),

          // Action Buttons
          SecondaryButton(
            text: AppText.askClarification,
            onPressed: controller.askClarification,
            backgroundColor: Colors.transparent,
            textColor: AppColors.primaryBlue,
            border: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            width: double.infinity,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: AppText.reject,
                  onPressed: controller.rejectRequest,
                  backgroundColor: Theme.of(
                    context,
                  ).disabledColor.withOpacity(0.2),
                  textColor: AppColors.textDark,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: PrimaryButton(
                  text: AppText.approve,
                  onPressed: controller.approveRequest,
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  // --- COMMON WIDGETS ---

  // --- ATTACHMENTS SECTION ---
  Widget _buildAttachmentsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: AppColors.textDark,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Bill & Attachments",
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth =
                  (constraints.maxWidth - 16.w) / 2; // 2 items per row with gap
              return Wrap(
                spacing: 16.w,
                runSpacing: 16.w,
                children: _buildAttachmentButtons(context, itemWidth),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAttachmentButtons(BuildContext context, double width) {
    final req = controller.request;
    final buttons = <Widget>[];

    // Determine URLs
    List<String> billUrls = [];
    if (req['bill_urls'] != null && req['bill_urls'] is List) {
      billUrls = List<String>.from(req['bill_urls']);
    } else if (req['bill_url'] != null) {
      billUrls.add(req['bill_url']);
    } else if (req['attachments'] is List &&
        (req['attachments'] as List).isNotEmpty) {
      final first = (req['attachments'] as List).first;
      if (first is Map)
        billUrls.add(first['file_url'] ?? first['url']);
      else if (first is String)
        billUrls.add(first);
    }

    // Receipt: 'receipt_url'
    String? receiptUrl = req['receipt_url'];

    // QR: 'qr_url' (primary) or 'qr_code_url'
    String? qrUrl = req['qr_url'] ?? req['qr_code_url'];

    // Logic based on Request Type

    // Buttons for Bills
    if (billUrls.isNotEmpty) {
      for (int i = 0; i < billUrls.length; i++) {
        if (billUrls[i].isNotEmpty) {
          buttons.add(
            _buildAttachmentOption(
              context: context,
              icon: Icons.receipt_long_rounded,
              label: billUrls.length > 1 ? "View Bill ${i + 1}" : "View Bill",
              onTap: () => controller.viewAttachment(billUrls[i]),
              width: width,
            ),
          );
        }
      }
    }

    // Button 2: View QR (If available)
    if (qrUrl != null && qrUrl.isNotEmpty) {
      buttons.add(
        _buildAttachmentOption(
          context: context,
          icon: Icons.qr_code_2_rounded,
          label: "View QR",
          onTap: () => controller.viewAttachment(qrUrl!),
          width: width,
        ),
      );
    }

    // Button 3: View Receipt (If available)
    if (receiptUrl != null && receiptUrl.isNotEmpty) {
      buttons.add(
        _buildAttachmentOption(
          context: context,
          icon: Icons.check_circle_outline_rounded,
          label: "View Receipt",
          onTap: () => controller.viewAttachment(receiptUrl!),
          width: width,
        ),
      );
    }

    if (buttons.isEmpty) {
      return [
        Text(
          "No attachments available.",
          style: TextStyle(color: AppColors.textSlate, fontSize: 13.sp),
        ),
      ];
    }

    return buttons;
  }

  Widget _buildAttachmentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16.r),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE), // Sky 100
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0284C7),
                size: 24.sp,
              ), // Sky 600
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: AppTextStyles.h3.copyWith(
                fontSize: 14.sp,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.information,
            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 24.h),
          _buildLabelValue(
            "Request ID",
            "#${controller.request['id'] ?? controller.request['request_id'] ?? '---'}",
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Requestor",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSlate,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 12.r,
                      backgroundColor: const Color(0xFFE0F2FE),
                      child: Text(
                        _getInitials(_getUserName(controller.request)),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        _getUserName(controller.request),
                        style: AppTextStyles.h3.copyWith(fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildLabelValue(
            "Department",
            controller.request['department'] ?? 'General',
          ),
          SizedBox(height: 16.h),
          _buildLabelValue(
            "Submission Date",
            _formatDate(controller.request['created_at']?.toString() ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            // Expanded left side
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color: AppColors.warning,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  // Expanded text parsing
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment Status",
                        style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        controller.request['reimbursement_status'] ??
                            "Pending reimbursement",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                          fontSize: 13.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              controller.request['payment_status'] ?? "Pending",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalHistory(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.approvalTimeline.toUpperCase(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSlate,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 24.h),
          ..._buildDynamicHistory(),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required String title,
    required String date,
    String? user,
    String? description,
    Color? descriptionColor,
    required IconData icon,
    required Color iconColor,
    Color? iconBg,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: iconBg ?? iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconBg != null ? iconColor : iconColor,
                size: 14.sp,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 40.h,
                color: Theme.of(context).dividerColor,
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h3.copyWith(fontSize: 15.sp)),
              SizedBox(height: 2.h),
              Text(
                date,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSlate,
                  fontSize: 13.sp,
                ),
              ),
              if (user != null)
                Text(
                  user,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (description != null)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: descriptionColor ?? AppColors.textSlate,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionReasonCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05), // Light Red
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.comment_rounded,
                  color: AppColors.error,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppText.reasonForRejection.toUpperCase(),
                style: AppTextStyles.h3.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.error.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            controller.request['rejection_reason'] ??
                controller.request['remarks'] ??
                'No reason provided.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "${AppText.noteFromApprover} • ${_formatDate(controller.request['updated_at']?.toString() ?? '')}",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSlate,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.h3.copyWith(fontSize: 14.sp),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _getAvatarColor(String initials) {
    if (initials.isEmpty) return const Color(0xFFDBEAFE);
    final int hash = initials.codeUnits.fold(0, (p, c) => p + c);
    // Simple mock random color logic
    if (hash % 3 == 0) return const Color(0xFFDBEAFE); // Blue
    if (hash % 3 == 1) return const Color(0xFFF3E8FF); // Purple
    return const Color(0xFFFEF3C7); // Amber
  }

  String _getDepartment(Map<dynamic, dynamic> item) {
    // 1. Check top-level
    if (item['department'] != null && item['department'].toString().isNotEmpty)
      return item['department'].toString();
    if (item['department_name'] != null &&
        item['department_name'].toString().isNotEmpty)
      return item['department_name'].toString();

    // 2. Check nested 'requestor'
    if (item['requestor'] != null && item['requestor'] is Map) {
      final r = item['requestor'];
      if (r['department'] != null) return r['department'].toString();
      if (r['department_name'] != null) return r['department_name'].toString();
    }

    // 3. Check nested 'user'
    if (item['user'] != null && item['user'] is Map) {
      final u = item['user'];
      if (u['department'] != null) return u['department'].toString();
    }

    // 4. Return reasonable default
    return 'General';
  }

  Color _getAvatarTextColor(String initials) {
    if (initials.isEmpty) return const Color(0xFF1D4ED8);
    final int hash = initials.codeUnits.fold(0, (p, c) => p + c);
    if (hash % 3 == 0) return const Color(0xFF1D4ED8); // Blue
    if (hash % 3 == 1) return const Color(0xFF7E22CE); // Purple
    return const Color(0xFFB45309); // Amber
  }

  String _getUserName(Map<dynamic, dynamic> item) {
    // Check specific keys first
    if (item['user_name'] != null && item['user_name'].toString().isNotEmpty)
      return item['user_name'].toString();
    if (item['employee_name'] != null &&
        item['employee_name'].toString().isNotEmpty)
      return item['employee_name'].toString();

    // Check nested 'requestor' object (Primary)
    if (item['requestor'] != null) {
      if (item['requestor'] is Map) {
        final r = item['requestor'];
        final String firstName = r['first_name']?.toString() ?? '';
        final String lastName = r['last_name']?.toString() ?? '';
        if (firstName.isNotEmpty) {
          return "$firstName $lastName".trim();
        }
        if (r['email'] != null) return r['email'].toString().split('@').first;
      }
    }

    if (item['requestor_name'] != null &&
        item['requestor_name'].toString().isNotEmpty)
      return item['requestor_name'].toString();

    // Check nested 'user' object
    if (item['user'] != null) {
      if (item['user'] is Map) {
        final u = item['user'];
        if (u['name'] != null) return u['name'].toString();
        if (u['full_name'] != null) return u['full_name'].toString();
        if (u['first_name'] != null)
          return "${u['first_name']} ${u['last_name'] ?? ''}".trim();
        if (u['email'] != null) return u['email'].toString().split('@').first;
      } else if (item['user'] is String) {
        return item['user'];
      }
    }

    // Check nested 'employee' object
    if (item['employee'] != null) {
      if (item['employee'] is Map) {
        return item['employee']['name']?.toString() ??
            item['employee']['first_name']?.toString() ??
            'Unknown';
      } else if (item['employee'] is String) {
        return item['employee'];
      }
    }

    return AppText.unknownUser;
  }

  List<Widget> _buildDynamicHistory() {
    // If we have a 'history' list from backend, use it. Otherwise, construct one from status/dates.
    final history = <Widget>[];

    // 1. Submitted (Always present if created_at exists)
    if (controller.request['created_at'] != null) {
      history.add(
        _buildHistoryItem(
          Get.context!,
          title: AppText.requestSubmitted,
          date: _formatDate(controller.request['created_at']),
          user: _getUserName(controller.request),
          icon: Icons.check_rounded,
          iconColor: Colors.white,
          iconBg: AppColors.primaryBlue,
        ),
      );
    }

    // 2. Status specific
    final status = (controller.request['status'] ?? '')
        .toString()
        .toLowerCase();

    if (status == 'approved') {
      history.add(
        _buildHistoryItem(
          Get.context!,
          title: AppText.finalApproval,
          date: _formatDate(controller.request['updated_at'] ?? ''),
          user: controller.request['approver_name'] ?? 'Approver',
          icon: Icons.check_rounded,
          iconColor: Colors.white,
          iconBg: AppColors.successGreen,
          isLast: true,
        ),
      );
    } else if (status == 'rejected') {
      history.add(
        _buildHistoryItem(
          Get.context!,
          title: AppText.statusRejected,
          date: _formatDate(controller.request['updated_at'] ?? ''),
          description:
              controller.request['rejection_reason'] ?? 'Reason not specified',
          descriptionColor: AppColors.error,
          icon: Icons.cancel,
          iconColor: AppColors.error,
          iconBg: AppColors.error.withOpacity(0.1),
          isLast: true,
        ),
      );
    }

    if (history.isEmpty) {
      return [
        Text(
          "No history available",
          style: TextStyle(color: AppColors.textSlate),
        ),
      ];
    }

    return history;
  }

  String _formatDateShort(String dateStr) {
    if (dateStr.isEmpty) return '---';
    try {
      final dt = DateTime.parse(dateStr);
      final List<String> months = [
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
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '---';
    try {
      final dt = DateTime.parse(dateStr);
      final List<String> months = [
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
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year} • ${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    } catch (_) {
      return dateStr;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
