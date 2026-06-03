import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import '../date_helper.dart';
import 'attachment_card.dart';

/// Status variants supported by [RequestDetailsLayout]. Drives the gradient
/// header colour, status pill text, and which optional sections render
/// (rejection reason, approval timeline).
enum RequestDetailVariant {
  pending,
  approved,
  rejected,
  /// Accountant view — the expense was already approved and is now awaiting
  /// payment. Uses the approved palette but suppresses the timeline since
  /// the bottom actions handle the workflow.
  awaitingPayment,
}

/// One shared expense-details layout used by:
///   * Admin request details (pending / approved / rejected)
///   * Accountant payment-flow request details
///   * Requestor's read-only view
///
/// Renders the same visual pattern as the admin screen — gradient hero
/// header (amount + REQUEST ID + chips), requestor card, details card,
/// attachments, optional rejection reason / timeline — so every flow
/// surfaces an identical look. The caller passes the expense Map plus a
/// variant; an optional [bottomBar] receives whatever action row the role
/// needs (e.g. "Mark as Paid" for accountant, "Approve / Reject" for
/// admin pending).
class RequestDetailsLayout extends StatelessWidget {
  /// Backend expense Map. Both `Map<String, dynamic>` and
  /// `Map<dynamic, dynamic>` are accepted.
  final Map<dynamic, dynamic> request;

  /// Visual variant.
  final RequestDetailVariant variant;

  /// Optional override for the screen title (default: "Request Details").
  final String? headerTitle;

  /// Optional bottom action bar — typically a SafeArea-wrapped row of
  /// buttons. When null, no bottom bar is rendered.
  final Widget? bottomBar;

  const RequestDetailsLayout({
    super.key,
    required this.request,
    required this.variant,
    this.headerTitle,
    this.bottomBar,
  });


  @override
  Widget build(BuildContext context) {
    final style = _styleFor(variant);

    final amount = (request['amount'] as num?)?.toDouble() ?? 0.0;
    final requestId =
        (request['request_id'] ?? request['id'] ?? '---').toString();
    final purpose =
        (request['purpose'] ?? request['title'] ?? 'Untitled request')
            .toString();
    final description = (request['description'] ?? '').toString().trim();
    final category = _pretty((request['category'] ?? '').toString());
    final requestType = _pretty((request['request_type'] ?? '').toString());
    final createdAt = request['created_at']?.toString() ?? '';
    final updatedAt = request['updated_at']?.toString() ?? createdAt;
    final userName = _readUserName(request);
    final department = _readDepartment(request);
    final rejectionReason =
        (request['rejection_reason'] ?? request['admin_remarks'] ?? '')
            .toString()
            .trim();
    final hasActionRow = updatedAt.isNotEmpty && updatedAt != createdAt;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHero(
              context,
              style: style,
              amount: amount,
              requestId: requestId,
              category: category,
              requestType: requestType,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (variant == RequestDetailVariant.rejected &&
                        rejectionReason.isNotEmpty) ...[
                      _buildRejectionCard(
                          reason: rejectionReason, whenStr: updatedAt),
                      SizedBox(height: 16.h),
                    ],
                    _sectionLabel('REQUESTOR'),
                    SizedBox(height: 10.h),
                    _buildRequestorCard(
                        userName: userName, department: department),
                    SizedBox(height: 16.h),
                    _sectionLabel('DETAILS'),
                    SizedBox(height: 10.h),
                    _buildDetailsCard(
                      purpose: purpose,
                      description: description,
                      submittedAt: createdAt,
                      actionAt: hasActionRow ? updatedAt : null,
                      variant: variant,
                    ),
                    SizedBox(height: 16.h),
                    _sectionLabel('ATTACHMENTS'),
                    SizedBox(height: 10.h),
                    _buildAttachmentsCard(),
                    if (variant == RequestDetailVariant.approved) ...[
                      SizedBox(height: 16.h),
                      _sectionLabel('TIMELINE'),
                      SizedBox(height: 10.h),
                      _buildTimelineCard(
                        createdAt: createdAt,
                        updatedAt: hasActionRow ? updatedAt : null,
                      ),
                    ],
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomBar,
    );
  }

  // ── Variant style ────────────────────────────────────────────────────────
  _VariantStyle _styleFor(RequestDetailVariant v) {
    switch (v) {
      case RequestDetailVariant.approved:
      case RequestDetailVariant.awaitingPayment:
        return const _VariantStyle(
          gradientStart: Color(0xFF10B981),
          gradientEnd: Color(0xFF047857),
          statusIcon: Icons.check_circle_rounded,
          statusLabel: 'APPROVED',
        );
      case RequestDetailVariant.rejected:
        return const _VariantStyle(
          gradientStart: Color(0xFFE25C5C),
          gradientEnd: Color(0xFFB91C1C),
          statusIcon: Icons.block_rounded,
          statusLabel: 'REJECTED',
        );
      case RequestDetailVariant.pending:
        return const _VariantStyle(
          gradientStart: Color(0xFF7C68D4),
          gradientEnd: Color(0xFF5B45B0),
          statusIcon: Icons.hourglass_top_rounded,
          statusLabel: 'PENDING',
        );
    }
  }

  // ── Hero ─────────────────────────────────────────────────────────────────
  Widget _buildHero(
    BuildContext context, {
    required _VariantStyle style,
    required double amount,
    required String requestId,
    required String category,
    required String requestType,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [style.gradientStart, style.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  headerTitle ?? 'Request Details',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              _statusPill(style),
            ],
          ),
          SizedBox(height: 22.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${CurrencyFormatter.inrPrecise(amount)}',
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 40.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'REQUEST ID #$requestId',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
          ),
          if (category.isNotEmpty || requestType.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (category.isNotEmpty)
                  _heroChip(label: category, icon: Icons.label_outline_rounded),
                if (requestType.isNotEmpty)
                  _heroChip(
                    label: requestType,
                    icon: Icons.assignment_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(_VariantStyle style) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.statusIcon, color: Colors.white, size: 13.sp),
          SizedBox(width: 5.w),
          Text(
            style.statusLabel,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip({required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section primitives ───────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSlate,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildRequestorCard({
    required String userName,
    required String department,
  }) {
    final initials = _initialsFor(userName);
    return _whiteCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: const Color(0xFFE0F2FE),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  department,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard({
    required String purpose,
    required String description,
    required String submittedAt,
    required String? actionAt,
    required RequestDetailVariant variant,
  }) {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kvRow('Purpose', purpose, multiline: true),
          if (description.isNotEmpty && description != purpose) ...[
            _divider(),
            _kvRow('Description', description, multiline: true),
          ],
          _divider(),
          _kvRow(
            'Submitted',
            DateHelper.formatDateTime(submittedAt, fallback: '—'),
          ),
          if (actionAt != null) ...[
            _divider(),
            _kvRow(
              variant == RequestDetailVariant.rejected
                  ? 'Rejected on'
                  : variant == RequestDetailVariant.approved ||
                          variant == RequestDetailVariant.awaitingPayment
                      ? 'Approved on'
                      : 'Updated',
              DateHelper.formatDateTime(actionAt, fallback: '—'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kvRow(String label, String value, {bool multiline = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textSlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              maxLines: multiline ? null : 2,
              overflow: multiline ? null : TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: const Color(0xFFF1F5F9));

  // ── Rejection card ───────────────────────────────────────────────────────
  Widget _buildRejectionCard(
      {required String reason, required String whenStr}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFFECACA),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.format_quote_rounded,
                    size: 13.sp, color: const Color(0xFFB91C1C)),
              ),
              SizedBox(width: 10.w),
              Text(
                'REASON FOR REJECTION',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7F1D1D),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            reason,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F1D1D),
            ),
          ),
          if (whenStr.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Note from Approver • ${DateHelper.formatDateTime(whenStr, fallback: "—")}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Timeline ─────────────────────────────────────────────────────────────
  Widget _buildTimelineCard({
    required String createdAt,
    required String? updatedAt,
  }) {
    final hasApproval = updatedAt != null;
    return _whiteCard(
      child: Column(
        children: [
          if (hasApproval) ...[
            _timelineRow(
              icon: Icons.check_rounded,
              iconBg: const Color(0xFF10B981),
              title: 'Approved',
              subtitle: DateHelper.formatDateTime(updatedAt, fallback: '—'),
              highlight: true,
            ),
            _timelineConnector(),
          ],
          _timelineRow(
            icon: Icons.send_rounded,
            iconBg: AppColors.primaryBlue,
            title: 'Request submitted',
            subtitle: DateHelper.formatDateTime(createdAt, fallback: '—'),
            highlight: !hasApproval,
          ),
        ],
      ),
    );
  }

  Widget _timelineRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 16.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: highlight ? iconBg : AppColors.textDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: AppColors.textSlate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timelineConnector() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Container(width: 2, height: 22.h, color: const Color(0xFFE2E8F0)),
        ],
      ),
    );
  }

  // ── Attachments ──────────────────────────────────────────────────────────
  Widget _buildAttachmentsCard() {
    final items = _collectAttachments(request);
    if (items.isEmpty) {
      return _whiteCard(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Center(
          child: Text(
            'No attachments',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSlate,
            ),
          ),
        ),
      );
    }
    return _whiteCard(
      padding: EdgeInsets.all(12.w),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        // AttachmentCard handles its own tap (downloads / launches URL).
        itemBuilder: (_, i) => AttachmentCard(attachment: items[i], index: i),
      ),
    );
  }

  static List<Map<String, dynamic>> _collectAttachments(
      Map<dynamic, dynamic> req) {
    final out = <Map<String, dynamic>>[];
    final seen = <String>{};
    void add(String name, dynamic url) {
      if (url == null) return;
      final s = url.toString();
      if (s.isEmpty || !seen.add(s)) return;
      out.add({'name': name, 'url': s, 'file': s});
    }

    if (req['attachments'] is List) {
      for (final raw in (req['attachments'] as List)) {
        if (raw is Map) {
          add(
            raw['name']?.toString() ?? 'Attachment',
            raw['url'] ?? raw['file'] ?? raw['file_url'],
          );
        }
      }
    }
    add('Receipt', req['receipt_url']);
    add('QR Code', req['payment_qr_url'] ?? req['qr_url']);
    if (req['bill_urls'] is List) {
      final bills = req['bill_urls'] as List;
      for (int i = 0; i < bills.length; i++) {
        add(bills.length > 1 ? 'Bill ${i + 1}' : 'Bill', bills[i]);
      }
    } else if (req['bill_url'] != null) {
      add('Bill', req['bill_url']);
    }
    return out;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  static String _pretty(String raw) {
    if (raw.isEmpty) return '';
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }


  static String _initialsFor(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.elementAt(1)[0]).toUpperCase();
  }

  static String _readUserName(Map<dynamic, dynamic> item) {
    if (item['user_name'] != null &&
        item['user_name'].toString().isNotEmpty) {
      return item['user_name'].toString();
    }
    if (item['employee_name'] != null &&
        item['employee_name'].toString().isNotEmpty) {
      return item['employee_name'].toString();
    }
    if (item['requestor'] is Map) {
      final r = item['requestor'];
      final fn = r['first_name']?.toString() ?? '';
      final ln = r['last_name']?.toString() ?? '';
      if (fn.isNotEmpty) return '$fn $ln'.trim();
      if (r['email'] != null) return r['email'].toString().split('@').first;
    }
    if (item['requestor_name'] != null &&
        item['requestor_name'].toString().isNotEmpty) {
      return item['requestor_name'].toString();
    }
    if (item['user'] is Map) {
      final u = item['user'];
      if (u['name'] != null) return u['name'].toString();
      if (u['full_name'] != null) return u['full_name'].toString();
      if (u['first_name'] != null) {
        return '${u['first_name']} ${u['last_name'] ?? ''}'.trim();
      }
      if (u['email'] != null) return u['email'].toString().split('@').first;
    }
    return 'Unknown user';
  }

  static String _readDepartment(Map<dynamic, dynamic> item) {
    final direct = item['department'] ?? item['department_name'];
    if (direct != null && direct.toString().isNotEmpty) {
      return direct.toString();
    }
    if (item['requestor'] is Map) {
      final r = item['requestor'];
      final v = r['department'] ?? r['department_name'];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    if (item['user'] is Map) {
      final u = item['user'];
      if (u['department'] != null) return u['department'].toString();
    }
    return 'General';
  }
}

class _VariantStyle {
  final Color gradientStart;
  final Color gradientEnd;
  final IconData statusIcon;
  final String statusLabel;
  const _VariantStyle({
    required this.gradientStart,
    required this.gradientEnd,
    required this.statusIcon,
    required this.statusLabel,
  });
}
