import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../data/notification_model.dart';

class AccountantNotificationsController extends GetxController {
  final RxList<NotificationItem> _allNotifications = <NotificationItem>[].obs;

  List<NotificationItem> get allNotifications => _allNotifications;
  List<NotificationItem> get actionRequired => _allNotifications
      .where((n) => n.type == NotificationType.actionRequired)
      .toList();
  List<NotificationItem> get updates => _allNotifications
      .where((n) => n.type != NotificationType.actionRequired)
      .toList(); // Assuming others are updates

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    _allNotifications.assignAll([
      NotificationItem(
        id: '1',
        title: '3 Pending Payments',
        time: 'Now',
        type: NotificationType.actionRequired,
        body: '', // Special UI handling
        amount: '\$4,200.00',
      ),
      NotificationItem(
        id: '2',
        title: 'AWS Invoice #9921',
        time: 'Due Tomorrow',
        type: NotificationType.actionRequired, // Or generic
        amount: '\$450.00',
        icon: Icons.warning, // Special UI
      ),
      NotificationItem(
        id: '3',
        title: 'John Doe',
        time: 'Awaiting Payment',
        type: NotificationType.payment, // Pending payment
        amount: '\$1,250.00',
        image: 'https://i.pravatar.cc/150?u=john',
        ref: 'Travel Reimbursement',
      ),
      NotificationItem(
        id: '4',
        title: 'Uber for Business',
        time: 'Payment Processed',
        type: NotificationType.update,
        amount: '\$45.20',
        ref: 'PAID',
        iconBg: Colors.black, // Special logic in UI?
      ),
      NotificationItem(
        id: '5',
        title: 'Month-end Close',
        time: '5 transactions need reconciliation',
        type: NotificationType.update,
        ref: 'REVIEW',
        icon: Icons.receipt,
        iconBg: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
      ),
      NotificationItem(
        id: '6',
        title: 'System Update',
        time: '2d ago',
        type: NotificationType.info,
        body: 'Policy updated for Q4 expenses',
        icon: Icons.settings,
        iconBg: Colors.grey[200],
        iconColor: Colors.grey[600],
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
