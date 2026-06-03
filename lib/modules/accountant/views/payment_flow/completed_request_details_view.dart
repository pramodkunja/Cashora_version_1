import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/date_helper.dart';
import 'package:cash/modules/accountant/views/payment_flow/widgets/completed_audit_trail.dart';
import 'package:cash/modules/accountant/views/payment_flow/widgets/completed_attachments_card.dart';
import 'package:cash/modules/accountant/views/payment_flow/widgets/completed_payment_card.dart';
import 'package:cash/utils/app_text.dart';
import 'package:cash/utils/widgets/skeletons/skeleton_loader.dart';
import 'package:cash/modules/accountant/controllers/completed_request_details_controller.dart';

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
        return _buildBody(context, payment);
      }),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      children: [
        _buildHeader(context, referenceCode: '---'),
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

  Widget _buildBody(BuildContext context, Map<String, dynamic> payment) {
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

    // Department can come as a flat string OR nested under requestor/user.
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

    final vendorName = (payment['vendor_name'] ??
            payment['vendor'] ??
            payment['payee_name'] ??
            '')
        .toString()
        .trim();

    final purpose = payment['purpose']?.toString() ?? '---';
    final description = payment['description']?.toString() ?? '---';
    final categoryKey = payment['category']?.toString() ?? '';
    final categoryMap = {
      'office_supplies': 'Office Supplies',
      'travel': 'Travel',
      'meals': 'Meals',
      'software': 'Software',
      'hardware': 'Hardware',
    };
    final category = categoryMap[categoryKey] ??
        (categoryKey.replaceAll('_', ' ').capitalizeFirst ?? '---');

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
        _buildHeader(context, referenceCode: referenceCode),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
            child: Column(
              children: [
                _buildSuccessHero(
                  amount: amount,
                  requestDate: requestDate,
                  paymentDate: paymentDate,
                ),
                SizedBox(height: 14.h),
                _buildRequestInfoCard(
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

  // ────────────────────────────────── Header ─────────────────────────────

  Widget _buildHeader(BuildContext context, {required String referenceCode}) {
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
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '#$referenceCode',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── Success hero card ────────────────────────

  Widget _buildSuccessHero({
    required double amount,
    required String requestDate,
    required String paymentDate,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular success badge with ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 74.w,
                height: 74.w,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 58.w,
                height: 58.w,
                decoration: const BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded,
                    color: Colors.white, size: 32.sp),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Payment Successful',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            AppText.totalPaidAmount,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSlate,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${amount.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 34.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(child: _dateCell('Requested', requestDate)),
                Container(height: 32.h, width: 1.w, color: AppColors.slate100),
                Expanded(child: _dateCell('Paid', paymentDate)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCell(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSlate,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────── Request info ────────────────────────────

  Widget _buildRequestInfoCard({
    required String requestorName,
    required String department,
    required String purpose,
    required String description,
    required String category,
    required String referenceCode,
    String requestorEmail = '',
    String vendorName = '',
  }) {
    return _sectionCard(
      icon: Icons.description_rounded,
      title: AppText.requestInformation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(AppText.requestor, requestorName),
          if (requestorEmail.isNotEmpty) ...[
            _divider(),
            _infoRow('Email', requestorEmail),
          ],
          _divider(),
          _infoRow(AppText.department, department),
          if (vendorName.isNotEmpty) ...[
            _divider(),
            _infoRow('Paid To', vendorName),
          ],
          _divider(),
          _infoRowChip(AppText.category, category),
          _divider(),
          _infoBlock(AppText.purpose, purpose),
          _divider(),
          _infoBlock(AppText.description, description),
          _divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppText.referenceCode,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textSlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '#$referenceCode',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────── Audit trail ─────────────────────────────


  // ───────────────────────────── Helpers ─────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRowChip(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppColors.textSlate,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.purpleSurface,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBlock(String label, String value) {
    final hasValue = value.isNotEmpty && value != '---';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: AppColors.textSlate,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.slate100, width: 1),
          ),
          child: Text(
            hasValue ? value : 'Not provided',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
              color: hasValue ? AppColors.textDark : AppColors.slate300,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(height: 1.h, color: AppColors.slate100),
    );
  }

  /// Best-effort requestor name extraction across all backend shapes we
  /// have observed (flat, nested under `requestor`, nested under `user`,
  /// `created_by`, etc.).
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

  /// Best-effort requestor email extraction across the shapes the backend
  /// may ship: flat `requestor_email` / `email`, nested `requestor.email`,
  /// nested `user.email`.
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
