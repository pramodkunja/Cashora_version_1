import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../controllers/admin_request_details_controller.dart';
import 'widgets/admin_app_bar.dart';

class AdminClarificationView extends GetView<AdminRequestDetailsController> {
  const AdminClarificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(title: AppText.askClarificationTitle),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppText.requestDetails,
              style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 12.h),
            // Request Summary Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
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
                        Obx(() {
                          final req = controller.request;
                          final user =
                              req['user']?.toString() ??
                              req['employee_name']?.toString() ??
                              req['created_by']?.toString() ??
                              AppText.unknownUser;
                          return Text(
                            user,
                            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                          );
                        }),
                        SizedBox(height: 4.h),
                        Obx(() {
                          final req = controller.request;
                          final title =
                              req['title']?.toString() ??
                              req['purpose']?.toString() ??
                              AppText.expense;
                          return Text(
                            title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSlate,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Thumbnail or Icon
                  Obx(() {
                    final req = controller.request;
                    String? imageUrl;
                    if (req['receipt_url'] != null &&
                        req['receipt_url'].toString().isNotEmpty) {
                      imageUrl = req['receipt_url'].toString();
                    } else if (req['attachments'] is List &&
                        (req['attachments'] as List).isNotEmpty) {
                      final first = (req['attachments'] as List).first;
                      if (first is String) imageUrl = first;
                      if (first is Map)
                        imageUrl =
                            first['url'] ?? first['file'] ?? first['path'];
                    }

                    if (imageUrl != null &&
                        (imageUrl.endsWith('.jpg') ||
                            imageUrl.endsWith('.png') ||
                            imageUrl.endsWith('.jpeg'))) {
                      return Container(
                        height: 80.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                    return Container(
                      height: 80.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: AppColors.primaryBlue,
                        size: 32.sp,
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() {
              final req = controller.request;
              final String amount = (req['amount'] is num)
                  ? (req['amount'] as num).toStringAsFixed(2)
                  : (req['amount']?.toString() ?? '0.00');
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1), // Light Blue
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '₹$amount',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.primaryBlue,
                  ),
                ),
              );
            }),

            SizedBox(height: 32.h),
            Text(
              AppText.yourQuestions,
              style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: TextField(
                controller: controller.clarificationController,
                maxLines: 6,
                decoration: const InputDecoration.collapsed(
                  hintText: AppText.clarificationHint,
                  hintStyle: TextStyle(color: AppColors.textSlate),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            SizedBox(height: 100.h), // Spacer for bottom
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.all(24.r),
        child: SafeArea(
          child: PrimaryButton(
            text: AppText.sendBackForClarification,
            onPressed: () => controller.submitClarification(),
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
