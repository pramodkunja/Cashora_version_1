import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/timeline_item_widget.dart';
import '../../../../utils/widgets/attachment_card.dart';
import 'widgets/rejected_request_view.dart';

class RequestDetailsReadView extends StatelessWidget {
  const RequestDetailsReadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> initialRequest = Get.arguments ?? {};

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppText.requestDetails,
          style: AppTextStyles.h3.copyWith(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: _buildContent(context, initialRequest),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> request) {
    final String status = request['status'] ?? 'Pending';
    final String category = request['category'] ?? 'General';
    // Date Logic: Prefer 'created_at' for parsing, fallback to 'date'
    String dateStr =
        request['created_at']?.toString() ??
        request['date']?.toString() ??
        DateTime.now().toString();
    String date = dateStr;
    try {
      final DateTime dt = DateTime.parse(dateStr);
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
      date = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (e) {
      // If parsing fails, it might be already formatted or simple YYYY-MM-DD
      if (date.contains('T')) date = date.split('T')[0];
    }
    final String amount = (request['amount'] as double? ?? 0.0).toStringAsFixed(
      2,
    );
    final String title = request['title'] ?? 'Request';

    // Check for Rejected Status explicitly for Custom UI
    if (status.toLowerCase() == 'rejected') {
      return RejectedRequestView(request: request);
    }

    // Default UI for Approved/Pending
    // Status Styling
    // Status Styling (Case Insensitive)
    final isApproved =
        status.toLowerCase() == 'approved' ||
        status.toLowerCase() == 'auto_approved' ||
        status.toLowerCase() == 'paid';
    final statusColor = isApproved
        ? AppColors.successGreen
        : const Color(0xFFF59E0B);
    final statusBg = isApproved
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFFEF3C7);
    final statusIcon = isApproved ? Icons.check_circle : Icons.pending;
    final statusText = isApproved ? 'Approved' : 'Pending';

    // Category Icon Logic
    IconData catIcon = Icons.category;
    if (category.toLowerCase().contains('food') ||
        category.toLowerCase().contains('meal'))
      catIcon = Icons.restaurant;
    else if (category.toLowerCase().contains('travel'))
      catIcon = Icons.flight;
    else if (category.toLowerCase().contains('office'))
      catIcon = Icons.work;
    else if (category.toLowerCase().contains('transport'))
      catIcon = Icons.directions_car;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Icon & Title Header
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(catIcon, size: 40, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSlate,
                fontSize: 16,
              ),
            ),

            // 2. Amount
            const SizedBox(height: 8),
            Text(
              '₹$amount',
              style: AppTextStyles.h1.copyWith(
                fontSize: 48,
                letterSpacing: -1.0,
              ),
            ),

            // 3. Status Pill
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 4. Info Grid (Category & Date)
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Category',
                    category,
                    Icons.category,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Date',
                    date,
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 5. Description
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Description',
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                request['description'] ?? 'No description provided.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 6. Attachments
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Attachments',
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),

            Builder(
              builder: (context) {
                final List<dynamic> allAttachments = [];
                if (request['attachments'] != null &&
                    request['attachments'] is List) {
                  allAttachments.addAll(request['attachments']);
                }

                if (request['qr_url'] != null) {
                  allAttachments.add({
                    'name': 'QR Code',
                    'url': request['qr_url'],
                  });
                }
                if (request['receipt_url'] != null) {
                  allAttachments.add({
                    'name': 'Receipt',
                    'url': request['receipt_url'],
                  });
                }
                if (request['bill_urls'] != null &&
                    request['bill_urls'] is List) {
                  final bills = request['bill_urls'] as List;
                  for (int i = 0; i < bills.length; i++) {
                    allAttachments.add({
                      'name': 'Bill ${i + 1}',
                      'url': bills[i],
                    });
                  }
                } else if (request['bill_url'] != null) {
                  allAttachments.add({
                    'name': 'Bill',
                    'url': request['bill_url'],
                  });
                }

                if (allAttachments.isEmpty) {
                  return Text(
                    'No attachments',
                    style: TextStyle(color: Colors.grey[400]),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allAttachments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return AttachmentCard(
                      attachment: allAttachments[index],
                      index: index,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 40),
            const SizedBox(height: 24),

            const SizedBox(height: 24),

            // 7. Approval Timeline (New)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Timeline",
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[300] ?? Colors.grey.shade300, width: 2),
                ),
              ),
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.only(left: 24),
              child: _buildApprovalTimeline(context, request),
            ),

            const SizedBox(height: 40),

            // 8. Conversation History
            if ((request['clarifications'] != null &&
                    (request['clarifications'] as List).isNotEmpty) ||
                (request['admin_remarks'] != null &&
                    request['admin_remarks'].toString().isNotEmpty)) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppText.clarificationHistory,
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey[300]!, width: 2),
                  ),
                ),
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.only(left: 24),
                child: _buildConversationHistory(context, request),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalTimeline(
    BuildContext context,
    Map<String, dynamic> request,
  ) {
    // Basic lifecycle: Submitted -> [Approvals] -> Current Status
    final created = request['created_at']?.toString() ?? '';
    final updated = request['updated_at']?.toString() ?? '';
    final status = (request['status'] ?? 'Pending').toString();
    final isApproved =
        status.toLowerCase() == 'approved' ||
        status.toLowerCase() == 'auto_approved';
    final isRejected = status.toLowerCase() == 'rejected';

    return Column(
      children: [
        // 1. Submitted
        TimelineItemWidget(
          question: "Request Submitted",
          response: "Request created successfully",
          askedAt: _formatDate(created),
          respondedAt: "",
          approverName: "System",
          isSystemEvent:
              true, // You might need to update TimelineItemWidget to handle this look, or use a custom row
        ),

        // 2. Decision (if any)
        if (isApproved)
          TimelineItemWidget(
            question: "Request Approved",
            response: request['admin_remarks'] ?? "Approved by admin",
            askedAt: _formatDate(updated),
            respondedAt: "",
            approverName: request['approver_name'] ?? AppText.approver,
            isSystemEvent: true,
            isSuccess: true,
          ),

        if (isRejected)
          TimelineItemWidget(
            question: "Request Rejected",
            response: request['rejection_reason'] ?? "Rejected by admin",
            askedAt: _formatDate(updated),
            respondedAt: "",
            approverName: request['approver_name'] ?? AppText.approver,
            isSystemEvent: true,
            isError: true,
          ),
      ],
    );
  }

  Widget _buildConversationHistory(
    BuildContext context,
    Map<String, dynamic> request,
  ) {
    final clarifications = request['clarifications'] as List? ?? [];

    if (clarifications.isEmpty) {
      final adminComment = request['admin_remarks'] ?? request['comments'];
      if (adminComment != null && adminComment.toString().isNotEmpty) {
        return TimelineItemWidget(
          question: adminComment,
          response: '',
          askedAt: AppText.recently,
          respondedAt: '',
          approverName: AppText.approver,
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(clarifications.length, (index) {
        final item = clarifications[index];
        final String question = item['question'] ?? '';
        final String response = item['response'] ?? '';
        final String askedAt = _formatDate(item['asked_at']?.toString() ?? '');
        final String respondedAt = _formatDate(
          item['responded_at']?.toString() ?? '',
        );

        return TimelineItemWidget(
          question: question,
          response: response,
          askedAt: askedAt,
          respondedAt: respondedAt,
          approverName: AppText.approver,
        );
      }),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return AppText.recently;
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return AppText.recently;
    }
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: label == 'Category'
                  ? const Color(0xFFE0E7FF)
                  : const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: label == 'Category'
                  ? const Color(0xFF4338CA)
                  : const Color(0xFF7E22CE),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSlate,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
