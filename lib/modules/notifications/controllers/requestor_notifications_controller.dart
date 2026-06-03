import 'package:get/get.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../modules/notifications/data/notification_model.dart';

/// Requestor notification controller — reads live push notifications from FCMService.
///
/// Relevant events for requestors:
///   expense_approved, expense_rejected, clarification_required,
///   clarification_responded, expense_paid
class RequestorNotificationsController extends GetxController {
  FCMService get _fcm => Get.find<FCMService>();

  List<PushNotification> get allNotifications => _fcm.notifications.toList();

  List<PushNotification> get actionRequired => _fcm.notifications
      .where(
        (n) => n.eventType == NotificationEventType.clarificationRequired,
      )
      .toList();

  List<PushNotification> get updates => _fcm.notifications
      .where(
        (n) => [
          NotificationEventType.expenseApproved,
          NotificationEventType.expenseRejected,
          NotificationEventType.expensePaid,
          NotificationEventType.clarificationResponded,
        ].contains(n.eventType),
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
