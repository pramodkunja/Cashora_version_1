import 'package:get/get.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../modules/notifications/data/notification_model.dart';

/// Accountant notification controller — reads live push notifications from FCMService.
///
/// Relevant events for accountants:
///   expense_approved — approved expenses ready for payment
///   expense_paid     — payment completion confirmations
class AccountantNotificationsController extends GetxController {
  FCMService get _fcm => Get.find<FCMService>();

  List<PushNotification> get allNotifications => _fcm.notifications.toList();

  /// Approved expenses awaiting payment processing.
  List<PushNotification> get pendingPayment => _fcm.notifications
      .where(
        (n) => n.eventType == NotificationEventType.expenseApproved,
      )
      .toList();

  /// Completed/paid expense notifications.
  List<PushNotification> get completed => _fcm.notifications
      .where(
        (n) => n.eventType == NotificationEventType.expensePaid,
      )
      .toList();

  void markAllRead() {
    _fcm.markAllRead();
    Get.snackbar(
      'Notifications',
      'All notifications marked as read',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void markRead(String id) => _fcm.markRead(id);

  /// Expose the FCM observable list so views can use Obx.
  RxList<PushNotification> get notifications => _fcm.notifications;
}
