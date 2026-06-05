import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/auth_service.dart';
import '../../../../../utils/app_text.dart';
import '../../../controllers/create_request_controller.dart';
import 'review_request_section_card.dart';

/// Request details section card — lists requestor, request type, category,
/// purpose, and description rows on the review screen.
class ReviewRequestDetails extends StatelessWidget {
  final CreateRequestController controller;
  const ReviewRequestDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ReviewRequestSectionCard(
      icon: Icons.description_rounded,
      title: AppText.requestDetails,
      children: [
        ReviewRequestDetailRow(
          icon: Icons.person_rounded,
          label: 'Requestor',
          value:
              Get.find<AuthService>().currentUser.value?.name ?? 'Unknown',
        ),
        Obx(() => ReviewRequestDetailRow(
              icon: Icons.receipt_long_rounded,
              label: AppText.requestType,
              value: controller.requestType.value,
            )),
        Obx(() {
          final cat = controller.selectedExpenseCategory.value;
          return ReviewRequestDetailRow(
            icon: Icons.category_rounded,
            label: AppText.category,
            value: cat?['name'] ?? AppText.notSelected,
          );
        }),
        Obx(() => ReviewRequestDetailRow(
              icon: Icons.label_rounded,
              label: AppText.purpose,
              value: controller.purpose.value,
            )),
        Obx(() => ReviewRequestDetailRow(
              icon: Icons.notes_rounded,
              label: AppText.description,
              value: controller.description.value,
              last: true,
            )),
      ],
    );
  }
}
