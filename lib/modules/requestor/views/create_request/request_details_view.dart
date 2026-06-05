import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../controllers/create_request_controller.dart';
import 'widgets/create_request_amount_card.dart';
import 'widgets/create_request_attachments.dart';
import 'widgets/create_request_bottom_bar.dart';
import 'widgets/create_request_category_grid.dart';
import 'widgets/create_request_header.dart';
import 'widgets/create_request_primitives.dart';

class RequestDetailsView extends GetView<CreateRequestController> {
  const RequestDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          const CreateRequestHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CreateRequestAmountCard(controller: controller),
                  SizedBox(height: 14.h),

                  CreateRequestCategoryGrid(controller: controller),
                  SizedBox(height: 14.h),

                  CreateRequestSectionCard(
                    icon: Icons.description_rounded,
                    title: AppText.purpose,
                    child: CreateRequestTextField(
                      controller: controller.purposeController,
                      hint: AppText.purposeHint,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  CreateRequestSectionCard(
                    icon: Icons.notes_rounded,
                    title: AppText.descriptionOptional,
                    child: CreateRequestTextField(
                      controller: controller.descriptionController,
                      hint: AppText.descriptionPlaceholder,
                      maxLines: 4,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  CreateRequestSectionCard(
                    icon: Icons.edit_note_rounded,
                    title: 'Payment Note (Optional)',
                    child: CreateRequestTextField(
                      controller: controller.paymentNoteController,
                      hint: 'e.g. Pay to UPI: yourname@upi',
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  CreateRequestAttachments(controller: controller),
                ],
              ),
            ),
          ),
          CreateRequestBottomBar(controller: controller),
        ],
      ),
    );
  }
}
