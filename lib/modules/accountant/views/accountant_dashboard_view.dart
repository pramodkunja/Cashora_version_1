import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/accountant_dashboard_controller.dart';
import 'widgets/accountant_bottom_bar.dart';
import 'accountant_home_view.dart';
import 'accountant_payments_view.dart';
import 'accountant_profile_view.dart';
import 'analytics/spend_analytics_view.dart';

class AccountantDashboardView extends GetView<AccountantDashboardController> {
  const AccountantDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.rxIndex.value,
          children: const [
            AccountantHomeView(),
            AccountantPaymentsView(),
            SpendAnalyticsView(),
            AccountantProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => AccountantBottomBar(
          currentIndex: controller.rxIndex.value,
          onTap: controller.onBottomNavTap,
        ),
      ),
    );
  }
}
