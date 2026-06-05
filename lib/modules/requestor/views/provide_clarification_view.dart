import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/widgets/app_gradient_header.dart';
import '../../../../utils/app_text.dart';
import '../controllers/provide_clarification_controller.dart';
import 'widgets/provide_clarification_status_banner.dart';
import 'widgets/provide_clarification_request_card.dart';
import 'widgets/provide_clarification_conversation.dart';
import 'widgets/provide_clarification_response_form.dart';

class ProvideClarificationView extends GetView<ProvideClarificationController> {
  const ProvideClarificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          AppGradientHeader(title: AppText.provideClarificationTitle),
          Expanded(child: Obx(() => _buildBody(context))),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final request = controller.request;
    final status = request['status'] as String? ?? '';
    final isApproved = status == 'approved' || status == 'auto_approved';
    final isRejected = status == 'rejected';

    // Show the response form only when the LATEST clarification has an
    // outstanding question (response is empty). After the requestor
    // submits, the local optimistic update marks the response as set, so
    // the form hides automatically until the admin asks again.
    final isPendingMyResponse =
        _hasOutstandingClarification(request) && !isApproved && !isRejected;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProvideClarificationStatusBanner(
                  isPending: isPendingMyResponse,
                  isApproved: isApproved,
                  isRejected: isRejected,
                ),
                SizedBox(height: 18.h),

                _sectionLabel('REQUEST DETAILS'),
                SizedBox(height: 10.h),
                ProvideClarificationRequestCard(request: request),
                SizedBox(height: 20.h),

                _sectionLabel('CLARIFICATION HISTORY'),
                SizedBox(height: 10.h),
                ProvideClarificationConversation(request: request),

                if (isPendingMyResponse) ...[
                  SizedBox(height: 20.h),
                  _sectionLabel('YOUR RESPONSE'),
                  SizedBox(height: 10.h),
                  ProvideClarificationResponseForm(controller: controller),
                ],

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ],
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
          color: AppColors.textSlate,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Returns true when the latest clarification has a question but no
  /// response yet. That's the only state where the requestor needs to type
  /// and submit — after responding, this returns false until the admin
  /// asks again (which appends a new clarification with an empty response).
  bool _hasOutstandingClarification(Map request) {
    final raw = request['clarifications'];
    if (raw is! List || raw.isEmpty) return false;
    final last = raw.last;
    if (last is! Map) return false;
    final question = last['question']?.toString().trim() ?? '';
    final response = last['response']?.toString().trim() ?? '';
    return question.isNotEmpty && response.isEmpty;
  }
}
