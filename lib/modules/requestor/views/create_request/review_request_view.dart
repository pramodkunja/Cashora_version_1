import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/create_request_controller.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/widgets/app_gradient_header.dart';
import '../../../../utils/app_text.dart';
import 'widgets/review_request_amount_card.dart';
import 'widgets/review_request_attachments.dart';
import 'widgets/review_request_bottom_bar.dart';
import 'widgets/review_request_details.dart';

class ReviewRequestView extends GetView<CreateRequestController> {
  const ReviewRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          AppGradientHeader(title: AppText.reviewRequest),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                children: [
                  ReviewRequestAmountCard(controller: controller),
                  SizedBox(height: 16.h),
                  ReviewRequestDetails(controller: controller),
                  SizedBox(height: 16.h),
                  ReviewRequestAttachments(controller: controller),
                ],
              ),
            ),
          ),
          ReviewRequestBottomBar(controller: controller),
        ],
      ),
    );
  }
}
