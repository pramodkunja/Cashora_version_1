import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/date_helper.dart';
import '../../../../utils/widgets/attachment_card.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../controllers/admin_clarification_status_controller.dart';

class AdminClarificationStatusView
    extends GetView<AdminClarificationStatusController> {
  const AdminClarificationStatusView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Obx(() => _buildBody(context)),
      bottomNavigationBar: Obx(() => _buildBottomBar(context)),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Body — same shell across all clarification states. State only changes
  // the gradient pill (Awaiting/Responded), whether the ask-again textarea
  // is shown, and the bottom bar.
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildBody(BuildContext context) {
    try {
      final req = controller.request;
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
      final state = controller.state.value;
      final isResponded = state == ClarificationState.responded;
      final isAsking = state == ClarificationState.askingAgain;

      return SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHero(
              context,
              isResponded: isResponded,
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
                    _sectionLabel('REQUESTOR'),
                    SizedBox(height: 10.h),
                    _buildRequestorCard(
                      userName: userName,
                      department: department,
                    ),
                    SizedBox(height: 16.h),

                    _sectionLabel('DETAILS'),
                    SizedBox(height: 10.h),
                    _buildDetailsCard(
                      purpose: purpose,
                      description: description,
                      submittedAt: createdAt,
                      updatedAt: updatedAt != createdAt ? updatedAt : null,
                    ),
                    SizedBox(height: 16.h),

                    _sectionLabel('ATTACHMENTS'),
                    SizedBox(height: 10.h),
                    _buildAttachmentsCard(req),
                    SizedBox(height: 16.h),

                    _sectionLabel('CLARIFICATION HISTORY'),
                    SizedBox(height: 10.h),
                    Obx(() => _buildConversationCard(context)),

                    if (isAsking) ...[
                      SizedBox(height: 16.h),
                      _sectionLabel('NEW QUESTION'),
                      SizedBox(height: 10.h),
                      _buildAskAgainField(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('ERROR rendering Clarification view: $e');
        debugPrint(stack.toString());
      }
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            '${AppText.errorDisplayingDetails}\n\n$e',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  // ── Hero ─────────────────────────────────────────────────────────────
  Widget _buildHero(
    BuildContext context, {
    required bool isResponded,
    required double amount,
    required String requestId,
    required String category,
    required String requestType,
  }) {
    final start =
        isResponded ? const Color(0xFF10B981) : const Color(0xFF7C68D4);
    final end = isResponded ? const Color(0xFF047857) : const Color(0xFF5B45B0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 12.h,
        20.w,
        22.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start, end],
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
                onTap: () {
                  if (controller.state.value == ClarificationState.askingAgain) {
                    controller.state.value = ClarificationState.responded;
                  } else {
                    Get.back();
                  }
                },
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
                  AppText.reviewClarification,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isResponded
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_top_rounded,
                      color: Colors.white,
                      size: 13.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      isResponded ? 'RESPONDED' : 'AWAITING',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${CurrencyFormatter.inr(amount)}',
              maxLines: 1,
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 40.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'REQUEST ID #$requestId',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
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
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section primitives ─────────────────────────────────────────────────
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
                  // Explicit colour — AppTextStyles.h3 inherits from
                  // Get.theme.textTheme which can resolve to null in
                  // this context, making the name invisible.
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
    required String? updatedAt,
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
          if (updatedAt != null) ...[
            _divider(),
            _kvRow(
              'Last update',
              DateHelper.formatDateTime(updatedAt, fallback: '—'),
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

  // ── Attachments ────────────────────────────────────────────────────────
  Widget _buildAttachmentsCard(Map<dynamic, dynamic> req) {
    final items = _collectAttachments(req);
    if (items.isEmpty) {
      return _whiteCard(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Center(
          child: Text(
            'No attachments',
            style: AppTextStyles.bodyMedium.copyWith(
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
        itemBuilder: (_, i) => AttachmentCard(attachment: items[i], index: i),
      ),
    );
  }

  List<Map<String, dynamic>> _collectAttachments(Map<dynamic, dynamic> req) {
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
          final url = raw['url'] ?? raw['file'];
          add(raw['name']?.toString() ?? 'Attachment', url);
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
    }
    return out;
  }

  // ── Conversation thread ────────────────────────────────────────────────
  Widget _buildConversationCard(BuildContext context) {
    final clarifications = controller.clarifications.toList();
    if (kDebugMode) {
      debugPrint('[Clarification][view] rxList size = ${clarifications.length}');
    }
    if (clarifications.isEmpty) {
      return _whiteCard(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Center(
          child: Text(
            'No clarification history yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSlate,
            ),
          ),
        ),
      );
    }

    final requestorName = _getUserName(controller.request);

    return _whiteCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: clarifications.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final question = item['question']?.toString() ?? '';
          final response = item['response']?.toString() ?? '';
          final askedAt = item['asked_at']?.toString() ?? '';
          final respondedAtRaw = item['responded_at']?.toString() ?? '';
          final hasResponse =
              response.isNotEmpty && respondedAtRaw.isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(
              bottom: idx == clarifications.length - 1 ? 0 : 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (question.isNotEmpty)
                  _msg(
                    fromApprover: true,
                    text: question,
                    time: DateHelper.formatDateTime(askedAt,
                        fallback: AppText.recently),
                  ),
                if (hasResponse) ...[
                  SizedBox(height: 10.h),
                  _msg(
                    fromApprover: false,
                    text: response,
                    time: DateHelper.formatDateTime(respondedAtRaw,
                        fallback: AppText.recently),
                    label: requestorName,
                  ),
                ] else if (response.isEmpty) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFFEF3C7)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hourglass_top_rounded,
                                size: 10.sp, color: const Color(0xFFB45309)),
                            SizedBox(width: 4.w),
                            Text(
                              'Waiting for response',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _msg({
    required bool fromApprover,
    required String text,
    required String time,
    String? label,
  }) {
    final bg = fromApprover ? AppColors.purpleSurface : AppColors.mintBg;
    final accent = fromApprover ? AppColors.primary : AppColors.successGreen;
    final headLabel = fromApprover ? AppText.youApprover : (label ?? 'Requestor');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          fromApprover ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: fromApprover
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    headLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    time,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.textSlate,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(fromApprover ? 4.r : 14.r),
                    topRight: Radius.circular(fromApprover ? 14.r : 4.r),
                    bottomLeft: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r),
                  ),
                ),
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Ask-again textarea (inline when state == askingAgain) ──────────────
  Widget _buildAskAgainField(BuildContext context) {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller.reasonController,
            maxLines: 5,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: AppText.explainWhy,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSlate.withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              AppText.makeItClear,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.sp,
                color: AppColors.textSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Bottom bar — state-driven (responded / pending / askingAgain).
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildBottomBar(BuildContext context) {
    final state = controller.state.value;

    if (state == ClarificationState.responded) {
      return _bottomShell(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: controller.startAskAgain,
                icon: Icon(Icons.help_outline_rounded,
                    color: AppColors.primaryBlue, size: 18.sp),
                label: Text(
                  AppText.askClarification,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: AppColors.primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                      onPressed: controller.reject,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        AppText.reject,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: controller.approve,
                      icon: Icon(Icons.check, color: Colors.white, size: 18.sp),
                      label: Text(
                        AppText.approve,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (state == ClarificationState.askingAgain) {
      return _bottomShell(
        PrimaryButton(
          text: AppText.sendClarificationRequest,
          onPressed: controller.submitAskAgain,
          icon: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
        ),
      );
    }

    // pending — admin may want to add a follow-up question while waiting.
    return _bottomShell(
      SizedBox(
        width: double.infinity,
        height: 52.h,
        child: OutlinedButton.icon(
          onPressed: controller.startAskAgain,
          icon: Icon(Icons.help_outline_rounded,
              color: AppColors.primaryBlue, size: 18.sp),
          label: Text(
            'Ask Another Question',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomShell(Widget child) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
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
      child: SafeArea(top: false, child: child),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Helpers (formatting + nested-field readers).
  // ════════════════════════════════════════════════════════════════════════

  String _prettyCategory(String raw) {
    if (raw.isEmpty) return '';
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }


  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.elementAt(1)[0]).toUpperCase();
  }

  String _getDepartment(Map<dynamic, dynamic> item) {
    final direct = item['department'] ?? item['department_name'];
    if (direct != null && direct.toString().isNotEmpty) return direct.toString();
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

  String _getUserName(Map<dynamic, dynamic> item) {
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
    return AppText.unknownUser;
  }
}
