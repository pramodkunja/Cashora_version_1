import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../controllers/admin_history_controller.dart';
import 'widgets/admin_history_card.dart';
import 'widgets/admin_history_empty_state.dart';
import 'widgets/admin_history_filter_chips.dart';
import 'widgets/admin_history_header.dart';

class AdminHistoryView extends GetView<AdminHistoryController> {
  const AdminHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          AdminHistoryHeader(controller: controller),
          AdminHistoryFilterChips(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const SkeletonListView();
              }
              if (controller.filteredRequests.isEmpty) {
                return const AdminHistoryEmptyState();
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchHistory,
                child: ListView.separated(
                  controller: controller.scrollController,
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                  itemCount: controller.filteredRequests.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) {
                    final item = controller.filteredRequests[i];
                    return GestureDetector(
                      onTap: () => controller.viewDetails(item),
                      child: AdminHistoryCard(item: item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
