import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/widgets/lazy_indexed_stack.dart';
import '../controllers/accountant_dashboard_controller.dart';
import 'widgets/accountant_bottom_bar.dart';
import 'accountant_home_view.dart';
import 'accountant_payments_view.dart';
import 'accountant_profile_view.dart';
import 'analytics/spend_analytics_view.dart';

class AccountantDashboardView extends GetView<AccountantDashboardController> {
  const AccountantDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // LazyIndexedStack only builds a tab the first time it's shown. This
    // avoids the after-login lag from constructing all 4 tab subtrees
    // (and their Obx wirings + initial fetches) up front.
    return Scaffold(
      body: Obx(
        () => LazyIndexedStack(
          index: controller.rxIndex.value,
          builders: const [
            _buildHome,
            _buildPayments,
            _buildAnalytics,
            _buildProfile,
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

Widget _buildHome(BuildContext _) => const AccountantHomeView();
Widget _buildPayments(BuildContext _) => const AccountantPaymentsView();
Widget _buildAnalytics(BuildContext _) => const SpendAnalyticsView();
Widget _buildProfile(BuildContext _) => const AccountantProfileView();
