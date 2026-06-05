import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/admin_request_details_controller.dart';
import 'widgets/admin_pending_actions_bar.dart';
import 'widgets/admin_request_details_body.dart';
import 'widgets/admin_request_details_info_card.dart';

class AdminRequestDetailsView extends GetView<AdminRequestDetailsController> {
  const AdminRequestDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Obx(() {
        final variant = _resolveVariant();
        return AdminRequestDetailsBody(
          controller: controller,
          variant: variant,
        );
      }),
      bottomNavigationBar: Obx(() {
        final status = (controller.request['status'] ?? 'Pending')
            .toString()
            .toLowerCase();
        final isPending = !(status == 'approved' ||
            status == 'auto_approved' ||
            status == 'rejected');
        if (!isPending) return const SizedBox.shrink();
        return AdminPendingActionsBar(
          onAskClarification: controller.askClarification,
          onReject: controller.rejectRequest,
          onApprove: controller.approveRequest,
        );
      }),
    );
  }

  AdminRequestDetailsVariant _resolveVariant() {
    final status = (controller.request['status'] ?? 'Pending')
        .toString()
        .toLowerCase();
    if (status == 'approved' || status == 'auto_approved') {
      return AdminRequestDetailsVariant.approved;
    }
    if (status == 'rejected') {
      return AdminRequestDetailsVariant.rejected;
    }
    return AdminRequestDetailsVariant.pending;
  }
}
