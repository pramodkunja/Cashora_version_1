import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'admin_dashboard_view.dart';
import 'admin_approvals_view.dart';
import 'admin_history_view.dart';
import '../../profile/views/profile_view.dart';
import 'widgets/admin_bottom_bar.dart';

class AdminMainView extends GetView<AdminDashboardController> {
  const AdminMainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const AdminDashboardView(),
            const AdminApprovalsView(),
            const AdminHistoryView(),
            const ProfileView(isTab: true),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => AdminBottomBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
