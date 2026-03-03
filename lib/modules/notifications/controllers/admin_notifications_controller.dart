import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/notification_model.dart';

class AdminNotificationsController extends GetxController {
  final RxList<NotificationItem> _allNotifications = <NotificationItem>[].obs;

  List<NotificationItem> get allNotifications => _allNotifications;
  List<NotificationItem> get newRequests => _allNotifications
      .where((n) => n.type == NotificationType.newRequest)
      .toList();
  List<NotificationItem> get clarifications => _allNotifications
      .where((n) => n.type == NotificationType.clarification)
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
        title: 'Client Dinner - NYC Trip',
        time: '2h ago',
        type: NotificationType.newRequest,
        ref: 'Request #4092',
        amount: '\$1,250.00',
        image: 'https://i.pravatar.cc/150?u=sarah',
        isUrgent: true,
        isUnread: true,
        body:
            'Sarah Jenkins', // Storing Name in body for simple re-use or extend model
      ),
      NotificationItem(
        id: '2',
        title: 'Travel Reimbursement',
        time: '5h ago',
        type: NotificationType.newRequest,
        ref: 'Request #4088',
        amount: '\$450.00',
        image: 'https://i.pravatar.cc/150?u=mark',
        isUnread: true,
        body: 'Mark Lee',
        icon: Icons.flight,
      ),
      NotificationItem(
        id: '3',
        title: 'Added receipt to Request #402',
        time: '1d ago',
        type: NotificationType.clarification,
        ref: 'Office Supplies',
        amount: '\$12.50',
        image: 'https://i.pravatar.cc/150?u=emily',
        body: 'Emily Chen',
        badgeText: 'CLARIFIED',
        badgeColor: const Color(0xFF10B981),
        badgeBg: const Color(0xFFD1FAE5),
        icon: Icons.receipt_long,
      ),
      NotificationItem(
        id: '4',
        title: 'Uber Ride to Airport',
        time: '1d ago',
        type: NotificationType.newRequest,
        ref: 'Transport',
        amount: '\$89.00',
        image: 'https://i.pravatar.cc/150?u=david',
        body: 'David Kim',
        icon: Icons.directions_car,
      ),
      NotificationItem(
        id: '5',
        title: 'Quarterly Software Licenses',
        time: '1d ago',
        type: NotificationType.newRequest,
        ref: 'Software',
        amount: '\$1,850.00',
        image: 'https://i.pravatar.cc/150?u=jessica',
        body: 'Jessica Stark',
        icon: Icons.computer,
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
