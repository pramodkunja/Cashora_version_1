import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../utils/widgets/timeline_item_widget.dart';
import '../controllers/provide_clarification_controller.dart';

class ProvideClarificationView extends GetView<ProvideClarificationController> {
  const ProvideClarificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppText.provideClarificationTitle,
          style: AppTextStyles.h3.copyWith(
            fontSize: 18.sp,
            color:
                Theme.of(context).appBarTheme.titleTextStyle?.color ??
                (isDark ? Colors.white : Colors.black),
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(child: Obx(() => _buildBody(context))),
    );
  }

  Widget _buildBody(BuildContext context) {
    final request = controller.request;
    final status = request['status'] as String? ?? '';
    final isPendingMyResponse =
        status == 'clarification_required' ||
        status == 'clarification_requested';
    final isApproved = status == 'approved' || status == 'auto_approved';
    final isRejected = status == 'rejected';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine Banner Colors & Icon
    Color bgColor;
    Color borderColor;
    Color iconColor;
    Color titleColor;
    Color subTitleColor;
    IconData icon;
    String title;
    String subTitle;

    if (isPendingMyResponse) {
      bgColor = isDark
          ? const Color(0xFF7C2D12).withOpacity(0.3)
          : const Color(0xFFFFF7ED); // Orange
      borderColor = isDark ? const Color(0xFF9A3412) : const Color(0xFFFFEDD5);
      iconColor = const Color(0xFFF97316);
      titleColor = isDark ? const Color(0xFFFB923C) : const Color(0xFF9A3412);
      subTitleColor = isDark
          ? const Color(0xFFFDBA74)
          : const Color(0xFFC2410C);
      icon = Icons.priority_high_rounded;
      title = AppText.actionRequired;
      subTitle = AppText.approverRequestedClarification;
    } else if (isApproved) {
      bgColor = isDark
          ? const Color(0xFF064E3B).withOpacity(0.3)
          : const Color(0xFFECFDF5); // Green
      borderColor = isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5);
      iconColor = const Color(0xFF10B981);
      titleColor = isDark ? const Color(0xFF34D399) : const Color(0xFF065F46);
      subTitleColor = isDark
          ? const Color(0xFF6EE7B7)
          : const Color(0xFF047857);
      icon = Icons.check_circle;
      title = AppText.approved;
      subTitle = AppText.requestApproved;
    } else if (isRejected) {
      bgColor = isDark
          ? const Color(0xFF7F1D1D).withOpacity(0.3)
          : const Color(0xFFFEF2F2); // Red
      borderColor = isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2);
      iconColor = const Color(0xFFEF4444);
      titleColor = isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B);
      subTitleColor = isDark
          ? const Color(0xFFFCA5A5)
          : const Color(0xFFB91C1C);
      icon = Icons.cancel;
      title = AppText.rejected;
      subTitle = AppText.rejected;
    } else {
      // Default: Response Sent / Pending Admin
      bgColor = isDark
          ? const Color(0xFF1E3A8A).withOpacity(0.3)
          : const Color(0xFFEFF6FF); // Blue
      borderColor = isDark ? const Color(0xFF1E40AF) : const Color(0xFFDBEAFE);
      iconColor = const Color(0xFF3B82F6);
      titleColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E40AF);
      subTitleColor = isDark
          ? const Color(0xFF93C5FD)
          : const Color(0xFF1D4ED8);
      icon = Icons.check;
      title = AppText.responseSent;
      subTitle = AppText.clarificationSubmittedWait;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          Container(
            margin: EdgeInsets.only(bottom: 24.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16.sp, color: Colors.white),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 16.sp,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subTitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: subTitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Text(
            AppText.requestDetails,
            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 12.h),
          _buildRequestDetailCard(context),
          SizedBox(height: 24.h),

          Text(
            AppText.clarificationHistory,
            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 12.h),

          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
            ),
            margin: EdgeInsets.only(left: 12.w),
            padding: EdgeInsets.only(left: 24.w),
            child: _buildConversationHistory(context),
          ),

          if (isPendingMyResponse) ...[
            SizedBox(height: 32.h),
            Text(
              AppText.yourResponseTitle,
              style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller.responseController,
                    maxLines: 5,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: AppText.typeYourExplanation,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSlate.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h, // Hard explicit height constraint
                    child: PrimaryButton(
                      text: AppText.submitResponse,
                      onPressed: controller.submitClarification,
                      isLoading: controller.isLoading.value,
                      icon: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestDetailCard(BuildContext context) {
    final request = controller.request;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String userName = AppText.unknownUser;
    if (request['employee_name'] != null)
      userName = request['employee_name'];
    else if (request['created_by_name'] != null)
      userName = request['created_by_name'];
    else if (request['user'] != null) {
      if (request['user'] is String)
        userName = request['user'];
      else if (request['user'] is Map && request['user']['name'] != null)
        userName = request['user']['name'];
    } else if (request['requestor_name'] != null)
      userName = request['requestor_name'];

    final String category =
        request['category'] ?? request['title'] ?? AppText.expense;
    final String amount = request['amount']?.toString() ?? '0.00';
    final String? receiptUrl = request['receipt_url'];

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  category,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSlate,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF075985).withOpacity(0.3)
                        : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "₹$amount",
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 14.sp,
                      color: const Color(0xFF0EA5E9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bill Image
          Container(
            height: 80.h,
            width: 80.w,
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16.r),
              image: receiptUrl != null && receiptUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(receiptUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: receiptUrl == null || receiptUrl.isEmpty
                ? const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.textSlate,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationHistory(BuildContext context) {
    final clarifications = controller.request['clarifications'] as List? ?? [];

    if (clarifications.isEmpty) {
      final adminComment =
          controller.request['admin_remarks'] ?? controller.request['comments'];
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
}
