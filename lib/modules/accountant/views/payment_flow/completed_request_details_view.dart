import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/date_helper.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/completed_request_details_controller.dart';
import 'widgets/completed_attachments_card.dart';
import 'widgets/completed_audit_trail.dart';
import 'widgets/completed_details_header.dart';
import 'widgets/completed_details_hero.dart';
import 'widgets/completed_details_info_card.dart';
import 'widgets/completed_payment_card.dart';

class CompletedRequestDetailsView extends StatelessWidget {
  const CompletedRequestDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompletedRequestDetailsController());

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SkeletonListView();
        }
        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorState(context, controller.errorMessage.value);
        }
        final payment = controller.paymentDetails;
        if (payment.isEmpty) {
          return _buildErrorState(context, 'No details available');
        }
        return _buildBody(payment);
      }),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      children: [
        const CompletedDetailsHeader(referenceCode: '---'),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48.sp, color: AppColors.slate300),
                  SizedBox(height: 12.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppColors.errorRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(Map<String, dynamic> payment) {
    final amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0;
    final createdAt = payment['created_at']?.toString() ?? '';
    final approvedAt = payment['approved_at']?.toString() ?? '';
    final paidAt = payment['paid_at']?.toString() ??
        payment['payment_date']?.toString() ??
        createdAt;

    final requestDate = DateHelper.formatDate(createdAt);
    final approvedDate = DateHelper.formatDate(approvedAt);
    final paymentDate = DateHelper.formatDate(paidAt);

    final requestorName = _readRequestorName(payment);
    final requestorEmail = _readRequestorEmail(payment);
    final department = _readDepartment(payment);
    final vendorName = (payment['vendor_name'] ??
            payment['vendor'] ??
            payment['payee_name'] ??
            '')
        .toString()
        .trim();

    final purpose = payment['purpose']?.toString() ?? '---';
    final description = payment['description']?.toString() ?? '---';
    final category = _prettyCategory(payment['category']?.toString() ?? '');

    final referenceCode = payment['request_id']?.toString() ??
        payment['id']?.toString() ??
        '---';
    final paymentMethod =
        (payment['payment_method'] ?? 'UPI').toString().toUpperCase();
    final transactionId =
        payment['transaction_reference']?.toString() ?? '---';
    final processedAt = _formatTime(paidAt);
    final auditTrail = payment['audit_trail'] as List? ?? [];

    final receiptUrl = payment['receipt_url']?.toString() ?? '';
    final paymentQrUrl = payment['payment_qr_url']?.toString() ?? '';
    final hasAttachments =
        receiptUrl.isNotEmpty || paymentQrUrl.isNotEmpty;

    return Column(
      children: [
        CompletedDetailsHeader(referenceCode: referenceCode),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
            child: Column(
              children: [
                CompletedDetailsHero(
                  amount: amount,
                  requestDate: requestDate,
                  paymentDate: paymentDate,
                ),
                SizedBox(height: 14.h),
                CompletedDetailsInfoCard(
                  requestorName: requestorName,
                  requestorEmail: requestorEmail,
                  department: department,
                  vendorName: vendorName,
                  purpose: purpose,
                  description: description,
                  category: category,
                  referenceCode: referenceCode,
                ),
                SizedBox(height: 14.h),
                CompletedPaymentCard(
                  method: paymentMethod,
                  transactionId: transactionId,
                  processedAt: processedAt,
                  approvedDate: approvedDate,
                  requestDate: requestDate,
                  paymentDate: paymentDate,
                ),
                if (hasAttachments) ...[
                  SizedBox(height: 14.h),
                  CompletedAttachmentsCard(
                    receiptUrl: receiptUrl,
                    paymentQrUrl: paymentQrUrl,
                  ),
                ],
                if (auditTrail.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  CompletedAuditTrail(auditTrail: auditTrail),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────── Data extraction ─────────────────────────
  //
  // The backend response shape has drifted across releases — these
  // helpers tolerate every variation we have observed (flat, nested
  // under `requestor`, nested under `user`, `created_by`, etc.).

  String _readRequestorName(Map<String, dynamic> payment) {
    String s(dynamic v) => v?.toString().trim() ?? '';
    bool ok(String v) => v.isNotEmpty && v.toLowerCase() != 'null';

    for (final k in const [
      'user_name',
      'employee_name',
      'requestor_name',
      'submitted_by_name',
      'created_by_name',
      'requested_by_name',
      'full_name',
      'name',
    ]) {
      final v = s(payment[k]);
      if (ok(v)) return v;
    }

    final flatFirst = s(payment['first_name']);
    final flatLast = s(payment['last_name']);
    if (ok(flatFirst)) return '$flatFirst $flatLast'.trim();

    for (final k in const [
      'requestor',
      'user',
      'employee',
      'created_by',
      'submitted_by',
      'requested_by',
      'submitter',
    ]) {
      final raw = payment[k];
      if (raw == null) continue;
      if (raw is String && ok(raw)) return raw;
      if (raw is Map) {
        for (final sub in const ['name', 'full_name', 'display_name']) {
          final v = s(raw[sub]);
          if (ok(v)) return v;
        }
        final f = s(raw['first_name']);
        final l = s(raw['last_name']);
        if (ok(f)) return '$f $l'.trim();
        final email = s(raw['email']);
        if (ok(email)) return email.split('@').first;
      }
    }

    final email = s(payment['email']);
    if (ok(email)) return email.split('@').first;

    debugPrint(
      '[completed_details] requestor name not found — keys=${payment.keys.toList()}',
    );
    return 'Unknown';
  }

  String _readRequestorEmail(Map<String, dynamic> payment) {
    String s(dynamic v) => v?.toString().trim() ?? '';
    bool ok(String v) => v.isNotEmpty && v.toLowerCase() != 'null';

    final flat = s(payment['requestor_email']);
    if (ok(flat)) return flat;

    for (final k in const ['requestor', 'user', 'employee']) {
      final raw = payment[k];
      if (raw is Map) {
        final e = s(raw['email']);
        if (ok(e)) return e;
      }
    }

    final bare = s(payment['email']);
    if (ok(bare)) return bare;

    return '';
  }

  String _readDepartment(Map<String, dynamic> payment) {
    String department = payment['department']?.toString() ?? '';
    if (department.isEmpty || department == 'null') {
      department = payment['department_name']?.toString() ?? '';
    }
    if (department.isEmpty || department == 'null') {
      final r = payment['requestor'];
      if (r is Map) {
        department = (r['department'] ?? r['department_name'] ?? '').toString();
      }
    }
    if (department.isEmpty || department == 'null') department = '---';
    return department;
  }

  String _prettyCategory(String raw) {
    const map = {
      'office_supplies': 'Office Supplies',
      'travel': 'Travel',
      'meals': 'Meals',
      'software': 'Software',
      'hardware': 'Hardware',
    };
    if (map.containsKey(raw)) return map[raw]!;
    if (raw.isEmpty) return '---';
    final pretty = raw
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    return pretty.isEmpty ? '---' : pretty;
  }

  String _formatTime(String dateStr) {
    if (dateStr.isEmpty) return '---';
    try {
      final dt = DateTime.parse(dateStr);
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m $amPm';
    } catch (_) {
      return dateStr;
    }
  }
}
