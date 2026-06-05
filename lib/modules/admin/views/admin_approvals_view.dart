import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/admin_approvals_controller.dart';
import 'widgets/admin_approvals_empty_state.dart';
import 'widgets/admin_approvals_header.dart';
import 'widgets/admin_approvals_request_card.dart';
import 'widgets/admin_approvals_tab_bar.dart';

class AdminApprovalsView extends StatefulWidget {
  const AdminApprovalsView({super.key});

  @override
  State<AdminApprovalsView> createState() => _AdminApprovalsViewState();
}

class _AdminApprovalsViewState extends State<AdminApprovalsView>
    with SingleTickerProviderStateMixin {
  late final AdminApprovalsController controller;
  late final TabController _tabController;
  late final Worker _initialTabWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminApprovalsController>();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: controller.initialTabIndex.value.clamp(0, 4),
    );
    // Listen for external requests from the dashboard's stat tiles. When
    // `initialTabIndex` is updated, animate the local TabController to
    // match. Using an explicit controller + worker avoids the brittle
    // DefaultTabController + ValueKey rebuild dance that was sometimes
    // ignored by Flutter's element tree (leading to taps from the
    // dashboard landing on the wrong sub-tab).
    _initialTabWorker = ever<int>(controller.initialTabIndex, (idx) {
      final target = idx.clamp(0, 4);
      if (_tabController.index != target) {
        _tabController.animateTo(target);
      }
    });
  }

  @override
  void dispose() {
    _initialTabWorker.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          const AdminApprovalsHeader(),
          AdminApprovalsTabBar(tabController: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTab(controller.pendingRequests, controller.pendingScroll),
                _buildTab(
                    controller.approvedRequests, controller.approvedScroll),
                _buildTab(controller.unpaidRequests, controller.unpaidScroll),
                _buildTab(controller.clarificationRequests,
                    controller.clarificationScroll),
                _buildTab(
                    controller.rejectedRequests, controller.rejectedScroll),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      RxList<Map<String, dynamic>> list, ScrollController scroll) {
    return Obx(() {
      if (controller.isLoading.value && list.isEmpty) {
        return const SkeletonListView();
      }
      if (list.isEmpty) return const AdminApprovalsEmptyState();
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.fetchAllRequests,
        child: ListView.separated(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
          itemCount: list.length,
          separatorBuilder: (_, _) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => AdminApprovalsRequestCard(
            item: list[i],
            onTap: () => controller.navigateToDetails(list[i]),
          ),
        ),
      );
    });
  }
}
