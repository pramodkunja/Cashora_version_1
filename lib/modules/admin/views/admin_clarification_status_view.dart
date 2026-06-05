import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../controllers/admin_clarification_status_controller.dart';
import 'widgets/admin_details_hero.dart';
import 'widgets/admin_clarification_conversation.dart';
import 'widgets/admin_clarification_bottom_bar.dart';
import 'widgets/admin_clarification_attachments.dart';
import 'widgets/admin_clar_status_section_label.dart';
import 'widgets/admin_clar_status_requestor_card.dart';
import 'widgets/admin_clar_status_details_card.dart';
import 'widgets/admin_clar_status_ask_again_field.dart';

class AdminClarificationStatusView
    extends GetView<AdminClarificationStatusController> {
  const AdminClarificationStatusView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Obx(() => _buildBody(context)),
      bottomNavigationBar: Obx(() => AdminClarificationBottomBar(
            state: controller.state.value,
            onAskAgain: controller.startAskAgain,
            onSubmitAskAgain: controller.submitAskAgain,
            onReject: controller.reject,
            onApprove: controller.approve,
          )),
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
            AdminDetailsHero(
              gradientStart: isResponded
                  ? const Color(0xFF10B981)
                  : const Color(0xFF7C68D4),
              gradientEnd: isResponded
                  ? const Color(0xFF047857)
                  : const Color(0xFF5B45B0),
              statusIcon: isResponded
                  ? Icons.check_circle_rounded
                  : Icons.hourglass_top_rounded,
              statusLabel: isResponded ? 'RESPONDED' : 'AWAITING',
              amount: amount,
              requestId: requestId,
              category: category,
              requestType: requestType,
              title: AppText.reviewClarification,
              onBack: () {
                if (controller.state.value ==
                    ClarificationState.askingAgain) {
                  controller.state.value = ClarificationState.responded;
                } else {
                  Get.back();
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdminClarStatusSectionLabel('REQUESTOR'),
                    SizedBox(height: 10.h),
                    AdminClarStatusRequestorCard(
                      userName: userName,
                      department: department,
                    ),
                    SizedBox(height: 16.h),

                    const AdminClarStatusSectionLabel('DETAILS'),
                    SizedBox(height: 10.h),
                    AdminClarStatusDetailsCard(
                      purpose: purpose,
                      description: description,
                      submittedAt: createdAt,
                      updatedAt: updatedAt != createdAt ? updatedAt : null,
                    ),
                    SizedBox(height: 16.h),

                    const AdminClarStatusSectionLabel('ATTACHMENTS'),
                    SizedBox(height: 10.h),
                    AdminClarificationAttachments(request: req),
                    SizedBox(height: 16.h),

                    const AdminClarStatusSectionLabel('CLARIFICATION HISTORY'),
                    SizedBox(height: 10.h),
                    Obx(() => AdminClarificationConversation(
                          clarifications: controller.clarifications.toList(),
                          requestorName: _getUserName(controller.request),
                        )),

                    if (isAsking) ...[
                      SizedBox(height: 16.h),
                      const AdminClarStatusSectionLabel('NEW QUESTION'),
                      SizedBox(height: 10.h),
                      AdminClarStatusAskAgainField(
                        controller: controller.reasonController,
                      ),
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
