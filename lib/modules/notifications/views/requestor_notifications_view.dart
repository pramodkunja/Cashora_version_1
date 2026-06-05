import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../controllers/requestor_notifications_controller.dart';
import '../data/notification_model.dart';
import 'widgets/requestor_notifications_list.dart';
import 'widgets/requestor_notifications_tab_bar.dart';
import 'widgets/requestor_notifications_test_menu.dart';
import 'widgets/requestor_notifications_top_bar.dart';

class RequestorNotificationView
    extends GetView<RequestorNotificationsController> {
  const RequestorNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RequestorNotificationsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: CashoraColors.bgB,
        floatingActionButton: kDebugMode
            ? FloatingActionButton(
                onPressed: () => RequestorNotificationsTestMenu.show(context),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.bug_report, color: Colors.white),
              )
            : null,
        body: Stack(
          children: [
            const AppBackground(extraBloom: true),
            SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  RequestorNotificationsTopBar(controller: controller),
                  SizedBox(height: 8.h),
                  const RequestorNotificationsTabBar(),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: Obx(
                      () => TabBarView(
                        children: [
                          RequestorNotificationsList(
                            items: controller.allNotifications,
                            emptySubtitle:
                                "You'll be notified about expense updates here.",
                            onItemTap: _handleItemTap,
                          ),
                          RequestorNotificationsList(
                            items: controller.actionRequired,
                            emptySubtitle:
                                'Clarification requests will appear here.',
                            onItemTap: _handleItemTap,
                          ),
                          RequestorNotificationsList(
                            items: controller.updates,
                            emptySubtitle:
                                'Status updates on your requests land here.',
                            onItemTap: _handleItemTap,
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

  void _handleItemTap(PushNotification item) {
    controller.markRead(item.id);
    final args = <String, dynamic>{
      'expense_id': item.expenseId,
      'request_id': item.requestId,
      'from_notification': true,
    };
    Get.toNamed('/request-details-read', arguments: args);
  }
}
