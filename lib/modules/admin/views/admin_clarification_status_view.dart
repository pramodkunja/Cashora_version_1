import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../controllers/admin_clarification_status_controller.dart';
import 'widgets/admin_app_bar.dart';

class AdminClarificationStatusView
    extends GetView<AdminClarificationStatusController> {
  const AdminClarificationStatusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AdminAppBar(
        title: AppText.reviewClarification,
        onBackPressed: () {
          if (controller.state.value == ClarificationState.askingAgain) {
            controller.state.value = ClarificationState.responded;
          } else {
            Get.back();
          }
        },
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.state.value == ClarificationState.askingAgain) {
            return _buildAskAgainBody(context);
          }
          return _buildStatusBody(context);
        }),
      ),
      bottomNavigationBar: Obx(() {
        Widget? bottomBar;
        if (controller.state.value == ClarificationState.responded) {
          bottomBar = Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            height: 110.h, // Explicit fixed height to prevent expansion
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: controller.reject,
                      child: Container(
                        height: 56.h, // Fixed button height
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(color: const Color(0xFFEF4444)),
                        ),
                        child: Center(
                          child: Text(
                            AppText.reject,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: InkWell(
                      onTap: controller.approve,
                      child: Container(
                        height: 56.h, // Fixed button height
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9), // Light Blue
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                AppText.approve,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (controller.state.value == ClarificationState.askingAgain) {
          bottomBar = Container(
            padding: EdgeInsets.all(24.r),
            color: Theme.of(context).cardColor,
            child: SafeArea(
              child: PrimaryButton(
                text: AppText.sendClarificationRequest,
                onPressed: controller.submitAskAgain,
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          );
        }

        return bottomBar ?? const SizedBox.shrink();
      }),
    );
  }

  Widget _buildStatusBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    try {
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
                color: controller.state.value == ClarificationState.responded
                    ? (isDark
                          ? const Color(0xFF064E3B).withOpacity(0.3)
                          : const Color(0xFFECFDF5)) // Green bg
                    : (isDark
                          ? const Color(0xFF7C2D12).withOpacity(0.3)
                          : const Color(0xFFFFF7ED)), // Orange bg
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: controller.state.value == ClarificationState.responded
                      ? (isDark
                            ? const Color(0xFF065F46)
                            : const Color(0xFFD1FAE5))
                      : (isDark
                            ? const Color(0xFF9A3412)
                            : const Color(0xFFFFEDD5)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color:
                          controller.state.value == ClarificationState.responded
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF97316),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.state.value == ClarificationState.responded
                          ? Icons.check
                          : Icons.hourglass_top_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.state.value == ClarificationState.responded
                              ? AppText.responseReceived
                              : AppText.waitingForResponse,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 16.sp,
                            color:
                                controller.state.value ==
                                    ClarificationState.responded
                                ? (isDark
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFF065F46))
                                : (isDark
                                      ? const Color(0xFFFB923C)
                                      : const Color(0xFF9A3412)),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          controller.state.value == ClarificationState.responded
                              ? AppText.requestorUpdatedDetails
                              : AppText.pendingUserResponse,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color:
                                controller.state.value ==
                                    ClarificationState.responded
                                ? (isDark
                                      ? const Color(0xFF6EE7B7)
                                      : const Color(0xFF047857))
                                : (isDark
                                      ? const Color(0xFFFDBA74)
                                      : const Color(0xFFC2410C)),
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
          ],
        ),
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint("ERROR rendering Admin Status Body: $e");
        debugPrint(stack.toString());
      }
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.0.r),
          child: Text(
            "${AppText.errorDisplayingDetails}\n\n$e",
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _buildAskAgainBody(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildConversationHistory(context),

          SizedBox(height: 24.h),
          Text(
            AppText.furtherClarificationNeeded,
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
                  controller: controller.reasonController,
                  maxLines: 5,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: AppText.explainWhy, // Reusing explainWhy
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSlate.withOpacity(0.7),
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
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetailCard(BuildContext context) {
    final request = controller.request;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Robust name mapping - Try deeper fallbacks
    final String userName = _getUserName(request);

    final String category =
        request['category'] ?? request['title'] ?? 'General Expense';
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
    // Safely extract clarifications — handle all possible runtime types
    final raw = controller.request['clarifications'];
    final List<Map<String, dynamic>> clarifications = [];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          clarifications.add(Map<String, dynamic>.from(item));
        }
      }
    }

    if (clarifications.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(
          'No clarification history available',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSlate),
        ),
      );
    }

    final String requestorName = _getUserName(controller.request);
    String initials = "U";
    if (requestorName.isNotEmpty) {
      final parts = requestorName.trim().split(" ");
      if (parts.length > 1 && parts[1].isNotEmpty) {
        initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
      } else {
        initials = requestorName[0].toUpperCase();
      }
    }

    return Column(
      children: clarifications.map((item) {
        final String question = item['question']?.toString() ?? '';
        final String response = item['response']?.toString() ?? '';
        final String askedAt = _formatDate(item['asked_at']?.toString() ?? '');
        final String respondedAt =
            _formatDate(item['responded_at']?.toString() ?? '');

        return _buildTimelineItem(
          context,
          question: question,
          response: response,
          askedAt: askedAt,
          respondedAt: respondedAt,
          requestorName: requestorName,
          initials: initials,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String question,
    required String response,
    required String askedAt,
    required String respondedAt,
    required String requestorName,
    required String initials,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Admin Question Node
        if (question.isNotEmpty)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -31.w, // Align with left border
                top: 0,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 24.h),
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A8A).withOpacity(0.5)
                                : const Color(0xFFDBEAFE),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 14.sp,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppText.youApprover,
                          style: AppTextStyles.h3.copyWith(fontSize: 14.sp),
                        ),
                        const Spacer(),
                        Text(
                          askedAt,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textSlate,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(question, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ],
          ),

        // 2. Requestor Response Node
        if (response.isNotEmpty)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -31.w, // Align with left border
                top: 0,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981), // Green dot
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 24.h),
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF064E3B).withOpacity(0.3)
                      : const Color(0xFFF0FDF4), // Light green bg
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF065F46)
                        : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 28.h,
                          width: 28.w,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF064E3B)
                                : const Color(0xFFDCFCE7),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            requestorName,
                            style: AppTextStyles.h3.copyWith(fontSize: 14.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          respondedAt,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textSlate,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(response, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return AppText.recently;
    try {
      final dt = DateTime.parse(dateStr);
      // minimalistic format
      return "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return AppText.recently;
    }
  }

  String _getUserName(Map<dynamic, dynamic> item) {
    // Check specific keys first
    if (item['user_name'] != null && item['user_name'].toString().isNotEmpty)
      return item['user_name'].toString();
    if (item['employee_name'] != null &&
        item['employee_name'].toString().isNotEmpty)
      return item['employee_name'].toString();

    // Check nested 'requestor' object (Primary)
    if (item['requestor'] != null) {
      if (item['requestor'] is Map) {
        final r = item['requestor'];
        final String firstName = r['first_name']?.toString() ?? '';
        final String lastName = r['last_name']?.toString() ?? '';
        if (firstName.isNotEmpty) {
          return "$firstName $lastName".trim();
        }
        if (r['email'] != null) return r['email'].toString().split('@').first;
      }
    }

    if (item['requestor_name'] != null &&
        item['requestor_name'].toString().isNotEmpty)
      return item['requestor_name'].toString();

    // Check nested 'user' object
    if (item['user'] != null) {
      if (item['user'] is Map) {
        final u = item['user'];
        if (u['name'] != null) return u['name'].toString();
        if (u['full_name'] != null) return u['full_name'].toString();
        if (u['first_name'] != null)
          return "${u['first_name']} ${u['last_name'] ?? ''}".trim();
        if (u['email'] != null) return u['email'].toString().split('@').first;
      } else if (item['user'] is String) {
        return item['user'];
      }
    }

    // Check nested 'employee' object
    if (item['employee'] != null) {
      if (item['employee'] is Map) {
        return item['employee']['name']?.toString() ??
            item['employee']['first_name']?.toString() ??
            'Unknown';
      } else if (item['employee'] is String) {
        return item['employee'];
      }
    }

    // Fallback aliases
    if (item['created_by_name'] != null)
      return item['created_by_name'].toString();

    return AppText.unknownUser;
  }
}
