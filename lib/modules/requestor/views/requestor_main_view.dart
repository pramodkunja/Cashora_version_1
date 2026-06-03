import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/requestor_controller.dart';
import 'requestor_dashboard_view.dart';
import 'my_requests_view.dart';
import '../../profile/views/profile_view.dart';
import 'widgets/requestor_bottom_bar.dart';

class RequestorMainView extends GetView<RequestorController> {
  const RequestorMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            RequestorDashboardView(),
            MyRequestsView(),
            ProfileView(isTab: true),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => RequestorBottomBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
