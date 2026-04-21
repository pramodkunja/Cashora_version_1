import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../controllers/provide_clarification_controller.dart';

class ProvideClarificationView extends GetView<ProvideClarificationController> {
  const ProvideClarificationView({Key? key}) : super(key: key);

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
  static const _red = AppColors.errorRed;
  static const _redBg = Color(0xFFFEF2F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: Obx(() => _buildBody(context))),
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
            AppText.provideClarificationTitle,
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

  Widget _buildBody(BuildContext context) {
    final request = controller.request;
    final status = request['status'] as String? ?? '';
    final isPendingMyResponse = status == 'clarification' ||
        status == 'clarification_requested' ||
        status == 'clarification_required';
    final isApproved = status == 'approved' || status == 'auto_approved';
    final isRejected = status == 'rejected';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                _statusBanner(
                  isPending: isPendingMyResponse,
                  isApproved: isApproved,
                  isRejected: isRejected,
                ),
                SizedBox(height: 18.h),

                _sectionLabel('REQUEST DETAILS'),
                SizedBox(height: 10.h),
                _buildRequestCard(),
                SizedBox(height: 20.h),

                _sectionLabel('CLARIFICATION HISTORY'),
                SizedBox(height: 10.h),
                _buildConversationCard(),

                if (isPendingMyResponse) ...[
                  SizedBox(height: 20.h),
                  _sectionLabel('YOUR RESPONSE'),
                  SizedBox(height: 10.h),
                  _buildResponseCard(),
                ],

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Status banner ────────────────────────────────────────────────
  Widget _statusBanner({
    required bool isPending,
    required bool isApproved,
    required bool isRejected,
  }) {
    late Color bg, color;
    late IconData icon;
    late String title, subtitle;

    if (isPending) {
      bg = _amberBg;
      color = _amber;
      icon = Icons.priority_high_rounded;
      title = AppText.actionRequired;
      subtitle = AppText.approverRequestedClarification;
    } else if (isApproved) {
      bg = _greenBg;
      color = _green;
      icon = Icons.check_circle_rounded;
      title = AppText.approved;
      subtitle = AppText.requestApproved;
    } else if (isRejected) {
      bg = _redBg;
      color = _red;
      icon = Icons.cancel_rounded;
      title = AppText.rejected;
      subtitle = AppText.rejected;
    } else {
      bg = _purpleLight;
      color = _purple;
      icon = Icons.mark_email_read_rounded;
      title = AppText.responseSent;
      subtitle = AppText.clarificationSubmittedWait;
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 16.sp, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Request card ─────────────────────────────────────────────────
  Widget _buildRequestCard() {
    final request = controller.request;
    String userName = AppText.unknownUser;
    if (request['employee_name'] != null) {
      userName = request['employee_name'];
    } else if (request['created_by_name'] != null) {
      userName = request['created_by_name'];
    } else if (request['user'] != null) {
      if (request['user'] is String) {
        userName = request['user'];
      } else if (request['user'] is Map &&
          request['user']['name'] != null) {
        userName = request['user']['name'];
      }
    } else if (request['requestor_name'] != null) {
      userName = request['requestor_name'];
    } else if (request['requestor'] is Map) {
      final r = request['requestor'];
      userName =
          '${r['first_name'] ?? ''} ${r['last_name'] ?? ''}'.trim();
      if (userName.isEmpty) userName = r['email']?.toString() ?? 'Unknown';
    }

    final category =
        request['category']?.toString() ?? request['title']?.toString() ?? AppText.expense;
    final amount = (request['amount'] is num)
        ? (request['amount'] as num).toDouble()
        : double.tryParse(request['amount']?.toString() ?? '0') ?? 0.0;
    final receiptUrl = request['receipt_url']?.toString();

    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _slate900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: _slate500,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(14.r),
              image: receiptUrl != null && receiptUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(receiptUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (receiptUrl == null || receiptUrl.isEmpty)
                ? Icon(Icons.receipt_long_rounded,
                    color: _purple, size: 28.sp)
                : null,
          ),
        ],
      ),
    );
  }

  // ── Conversation card (chat-style) ──────────────────────────────
  Widget _buildConversationCard() {
    final raw = controller.request['clarifications'];
    final List<Map<String, dynamic>> items = [];
    if (raw is List) {
      for (final it in raw) {
        if (it is Map) items.add(Map<String, dynamic>.from(it));
      }
    }

    if (items.isEmpty) {
      final adminComment = controller.request['admin_remarks'] ??
          controller.request['comments'];
      if (adminComment != null && adminComment.toString().isNotEmpty) {
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: _bubble(
            isApprover: true,
            text: adminComment.toString(),
            time: AppText.recently,
          ),
        );
      }
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            'No clarification history yet',
            style: GoogleFonts.inter(fontSize: 12.sp, color: _slate500),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          final question = item['question']?.toString() ?? '';
          final response = item['response']?.toString() ?? '';
          final askedAt = _formatDate(item['asked_at']?.toString() ?? '');
          final respondedAt =
              _formatDate(item['responded_at']?.toString() ?? '');
          return Column(
            children: [
              if (question.isNotEmpty)
                _bubble(isApprover: true, text: question, time: askedAt),
              if (response.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _bubble(isApprover: false, text: response, time: respondedAt),
              ],
              SizedBox(height: 10.h),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _bubble({
    required bool isApprover,
    required String text,
    required String time,
  }) {
    final bg = isApprover ? _purpleLight : _greenBg;
    final color = isApprover ? _purple : _green;
    final label = isApprover ? AppText.approver : 'You';
    final icon = isApprover ? Icons.support_agent_rounded : Icons.person_rounded;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          isApprover ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isApprover) _avatar(icon, color, bg),
        if (isApprover) SizedBox(width: 8.w),
        Flexible(
          child: Column(
            crossAxisAlignment:
                isApprover ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: _slate500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isApprover ? 4.r : 14.r),
                    topRight: Radius.circular(isApprover ? 14.r : 4.r),
                    bottomLeft: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r),
                  ),
                ),
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: _slate900,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isApprover) SizedBox(width: 8.w),
        if (!isApprover) _avatar(icon, color, bg),
      ],
    );
  }

  Widget _avatar(IconData icon, Color color, Color bg) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 16.sp, color: color),
    );
  }

  // ── Response card ────────────────────────────────────────────────
  Widget _buildResponseCard() {
    return Container(
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
          Container(
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: controller.responseController,
              maxLines: 5,
              style: GoogleFonts.inter(fontSize: 14.sp, color: _slate900),
              decoration: InputDecoration(
                hintText: AppText.typeYourExplanation,
                hintStyle:
                    GoogleFonts.inter(fontSize: 13.sp, color: _slate300),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.submitClarification,
                icon: controller.isLoading.value
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.send_rounded, size: 18.sp),
                label: Text(
                  AppText.submitResponse,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _purple.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
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
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: _slate500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return AppText.recently;
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return AppText.recently;
    }
  }
}
