import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../controllers/accountant_notifications_controller.dart';
import '../data/notification_model.dart';
import 'widgets/accountant_notifications_list.dart';
import 'widgets/accountant_notifications_tab_bar.dart';
import 'widgets/accountant_notifications_top_bar.dart';

class AccountantNotificationView
    extends GetView<AccountantNotificationsController> {
  const AccountantNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccountantNotificationsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: CashoraColors.bgB,
        body: Stack(
          children: [
            const AppBackground(extraBloom: true),
            SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  AccountantNotificationsTopBar(controller: controller),
                  SizedBox(height: 8.h),
                  const AccountantNotificationsTabBar(),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: Obx(
                      () => TabBarView(
                        children: [
                          AccountantNotificationsList(
                            items: controller.allNotifications,
                            emptySubtitle:
                                'Payment updates will appear here.',
                            onTapItem: _handleTap,
                          ),
                          AccountantNotificationsList(
                            items: controller.pendingPayment,
                            emptySubtitle:
                                'Approved requests waiting for payment.',
                            onTapItem: _handleTap,
                          ),
                          AccountantNotificationsList(
                            items: controller.completed,
                            emptySubtitle: 'Settled payments land here.',
                            onTapItem: _handleTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(PushNotification item) {
    controller.markRead(item.id);
    _navigateToExpense(item);
  }

  void _navigateToExpense(PushNotification item) {
    final args = <String, dynamic>{
      'expense_id': item.expenseId,
      'request_id': item.requestId,
      'from_notification': true,
    };
    Get.toNamed('/accountant/payment/request-details', arguments: args);
  }
}
