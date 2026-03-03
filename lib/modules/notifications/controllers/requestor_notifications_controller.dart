import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../data/notification_model.dart';

class RequestorNotificationsController extends GetxController {
  final RxList<NotificationItem> _allNotifications = <NotificationItem>[].obs;

  List<NotificationItem> get allNotifications => _allNotifications;
  List<NotificationItem> get actionRequired => _allNotifications
      .where((n) => n.type == NotificationType.actionRequired)
      .toList();
  List<NotificationItem> get approved => _allNotifications
      .where(
        (n) =>
            n.type == NotificationType.approved ||
            n.type == NotificationType.payment,
      )
      .toList();

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    _allNotifications.assignAll([
      NotificationItem(
        id: '1',
        title: 'Clarification Needed',
        time: '10m ago',
        type: NotificationType.actionRequired,
        ref: '#EXP-2023',
        body:
            'Please attach the itemized receipt for the client lunch at bistro.',
        isUrgent: true,
      ),
      NotificationItem(
        id: '2',
        title: 'Payment Processed',
        time: '2h ago',
        type: NotificationType.payment,
        ref: '#EXP-1998',
        amount: '\$120.50',
        body: 'sent to your account ending in ••••8842.',
        icon: Icons.payments_outlined,
        iconBg: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
      ),
      NotificationItem(
        id: '3',
        title: 'Request Approved',
        time: '1d ago',
        type: NotificationType.approved,
        ref: '#EXP-2020',
        body: 'Travel to NY Conference approved by Manager.',
        icon: Icons.check_circle_outline,
        iconBg: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
      ),
      NotificationItem(
        id: '4',
        title: 'Request Rejected',
        time: '5d ago',
        type: NotificationType.rejected,
        ref: '#EXP-1950',
        body: 'Alcohol purchase is not covered per company policy section 4.2.',
        icon: Icons.cancel_outlined,
        iconBg: const Color(0xFFFEE2E2),
        iconColor: const Color(0xFFEF4444),
      ),
      NotificationItem(
        id: '5',
        title: 'Policy Update',
        time: '6d ago',
        type: NotificationType.info,
        body: 'The mileage reimbursement rate has been updated for Q4.',
        icon: Icons.info_outline,
        iconBg: const Color(0xFFDBEAFE),
        iconColor: const Color(0xFF3B82F6),
      ),
    ]);
  }

  void markAllRead() {
    _allNotifications.clear();
    Get.snackbar(
      'Notifications',
      'All notifications cleared',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
