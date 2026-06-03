import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/date_helper.dart';
import '../controllers/admin_request_details_controller.dart';
import 'widgets/admin_attachments_section.dart';
import 'widgets/admin_timeline_card.dart';
import 'widgets/admin_request_banners.dart';
import 'widgets/admin_pending_actions_bar.dart';
import 'widgets/admin_details_hero.dart';

enum _DetailVariant { pending, approved, rejected }

class _VariantStyle {
  final Color gradientStart;
  final Color gradientEnd;
  final Color accent;
  final Color accentBg;
  final IconData statusIcon;
  final String statusLabel;
  const _VariantStyle({
    required this.gradientStart,
    required this.gradientEnd,
    required this.accent,
    required this.accentBg,
    required this.statusIcon,
    required this.statusLabel,
  });
}

class AdminRequestDetailsView extends GetView<AdminRequestDetailsController> {
  const AdminRequestDetailsView({super.key});


  static _VariantStyle _styleFor(_DetailVariant v) {
    switch (v) {
      case _DetailVariant.approved:
        return const _VariantStyle(
          gradientStart: Color(0xFF10B981),
          gradientEnd: Color(0xFF047857),
          accent: Color(0xFF047857),
          accentBg: Color(0xFFD1FAE5),
          statusIcon: Icons.check_circle_rounded,
          statusLabel: 'APPROVED',
        );
      case _DetailVariant.rejected:
        return const _VariantStyle(
          gradientStart: Color(0xFFE25C5C),
          gradientEnd: Color(0xFFB91C1C),
          accent: Color(0xFFB91C1C),
          accentBg: Color(0xFFFEE2E2),
          statusIcon: Icons.block_rounded,
          statusLabel: 'REJECTED',
        );
      case _DetailVariant.pending:
        return const _VariantStyle(
          gradientStart: Color(0xFF7C68D4),
          gradientEnd: Color(0xFF5B45B0),
          accent: AppColors.primary,
          accentBg: Color(0xFFF0EDFF),
          statusIcon: Icons.hourglass_top_rounded,
          statusLabel: 'PENDING',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Obx(() {
        final status = (controller.request['status'] ?? 'Pending')
            .toString()
            .toLowerCase();
        final _DetailVariant variant;
        if (status == 'approved' || status == 'auto_approved') {
          variant = _DetailVariant.approved;
        } else if (status == 'rejected') {
          variant = _DetailVariant.rejected;
        } else {
          variant = _DetailVariant.pending;
        }
        return _buildUnifiedBody(context, variant);
      }),
      bottomNavigationBar: Obx(() {
        final status = (controller.request['status'] ?? 'Pending')
            .toString()
            .toLowerCase();
        final isPending = !(status == 'approved' ||
            status == 'auto_approved' ||
            status == 'rejected');
        if (!isPending) return const SizedBox.shrink();
        return AdminPendingActionsBar(
          onAskClarification: controller.askClarification,
          onReject: controller.rejectRequest,
          onApprove: controller.approveRequest,
        );
      }),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Unified body — same layout across pending / approved / rejected.
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildUnifiedBody(BuildContext context, _DetailVariant variant) {
    final req = controller.request;
    final style = _styleFor(variant);

    final amount = (req['amount'] as num?)?.toDouble() ?? 0.0;
    final requestId =
        (req['request_id'] ?? req['id'] ?? '---').toString();
    final purpose =
        (req['purpose'] ?? req['title'] ?? 'Untitled request').toString();
    final description = (req['description'] ?? '').toString().trim();
    final category = _prettyCategory((req['category'] ?? '').toString());
    final requestType =
        _prettyCategory((req['request_type'] ?? '').toString());
    final createdAt = req['created_at']?.toString() ?? '';
    final updatedAt = req['updated_at']?.toString() ?? createdAt;
    final userName = _getUserName(req);
    final department = _getDepartment(req);
    final rejectionReason =
        (req['rejection_reason'] ?? req['admin_remarks'] ?? '')
            .toString()
            .trim();
    final hasUpdatedActionRow =
        updatedAt.isNotEmpty && updatedAt != createdAt;

    // Approved + payment still pending → surface an UNPAID notice at the
    // top of the body. The approvals tab calls this "Unpaid" too.
    final paymentStatus =
        (req['payment_status'] ?? '').toString().toLowerCase();
    final showUnpaidBanner =
        variant == _DetailVariant.approved && paymentStatus == 'pending';

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AdminDetailsHero(
            gradientStart: style.gradientStart,
            gradientEnd: style.gradientEnd,
            statusIcon: style.statusIcon,
            statusLabel: style.statusLabel,
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
                  // Rejection reason — only for rejected.
                  if (variant == _DetailVariant.rejected &&
                      rejectionReason.isNotEmpty) ...[
                    AdminRejectionCard(
                      reason: rejectionReason,
                      whenStr: updatedAt,
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Unpaid notice — approved but payment still pending.
                  if (showUnpaidBanner) ...[
                    const AdminUnpaidBanner(),
                    SizedBox(height: 16.h),
                  ],

                  _sectionLabel('REQUESTOR'),
                  SizedBox(height: 10.h),
                  _buildRequestorCard(userName: userName, department: department),
                  SizedBox(height: 16.h),

                  _sectionLabel('DETAILS'),
                  SizedBox(height: 10.h),
                  _buildDetailsCard(
                    purpose: purpose,
                    description: description,
                    submittedAt: createdAt,
                    actionAt: hasUpdatedActionRow ? updatedAt : null,
                    variant: variant,
                  ),
                  SizedBox(height: 16.h),

                  _sectionLabel('ATTACHMENTS'),
                  SizedBox(height: 10.h),
                  AdminAttachmentsSection(
                    request: controller.request,
                    onAttachmentTap: controller.viewAttachment,
                  ),
                  SizedBox(height: 16.h),

                  if (variant == _DetailVariant.approved) ...[
                    _sectionLabel('TIMELINE'),
                    SizedBox(height: 10.h),
                    AdminTimelineCard(
                      createdAt: createdAt,
                      updatedAt: hasUpdatedActionRow ? updatedAt : null,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
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
    final initials = _getInitials(userName);
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
                // Explicit colour — AppTextStyles.h3 inherits from
                // Get.theme.textTheme which can resolve to null /
                // white in this context, making the name invisible.
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  department,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSlate,
                    fontSize: 12.sp,
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
    required _DetailVariant variant,
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
              variant == _DetailVariant.rejected
                  ? 'Rejected on'
                  : variant == _DetailVariant.approved
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
              style: AppTextStyles.bodyMedium.copyWith(
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
              style: AppTextStyles.bodyMedium.copyWith(
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

  String _getDepartment(Map<dynamic, dynamic> item) {
    // 1. Check top-level
    if (item['department'] != null && item['department'].toString().isNotEmpty) {
      return item['department'].toString();
    }
    if (item['department_name'] != null &&
        item['department_name'].toString().isNotEmpty) {
      return item['department_name'].toString();
    }

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

  String _getUserName(Map<dynamic, dynamic> item) {
    String s(dynamic v) => v?.toString().trim() ?? '';
    bool ok(String v) => v.isNotEmpty && v.toLowerCase() != 'null';

    // ── 1. Direct flat keys backend may send ─────────────────────────
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
      final v = s(item[k]);
      if (ok(v)) return v;
    }

    // ── 2. Flat first_name / last_name pair (denormalized backends) ──
    final flatFirst = s(item['first_name']);
    final flatLast = s(item['last_name']);
    if (ok(flatFirst)) return '$flatFirst $flatLast'.trim();

    // ── 3. Nested objects in priority order ──────────────────────────
    for (final k in const [
      'requestor',
      'user',
      'employee',
      'created_by',
      'submitted_by',
      'requested_by',
      'submitter',
    ]) {
      final raw = item[k];
      if (raw == null) continue;
      if (raw is String && ok(raw)) return raw;
      if (raw is Map) {
        // Best-name lookup inside the nested object.
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

    // ── 4. Bare email at top level ───────────────────────────────────
    final email = s(item['email']);
    if (ok(email)) return email.split('@').first;

    // ── Debug aid: surface the keys backend actually sent so the team
    //    can tell us which one carries the name. Logged once per call.
    debugPrint(
      '[admin_request_details] requestor name not found — keys=${item.keys.toList()}',
    );
    return AppText.unknownUser;
  }

  /// snake_case / lower-case category enum → display (e.g.
  /// "office_supplies" → "Office Supplies", "pre_approved" → "Pre Approved").
  String _prettyCategory(String raw) {
    if (raw.isEmpty) return '';
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Indian-grouping currency formatter. e.g. 1234567.5 → "12,34,567.50".

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
