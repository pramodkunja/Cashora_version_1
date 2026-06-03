import 'package:get/get.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../modules/notifications/data/notification_model.dart';

/// Admin notification controller — reads live push notifications from FCMService.
///
/// Relevant events for admins:
///   clarification_responded (requester replied — admin must act)
///   expense_approved / expense_rejected (decisions made by admin — confirmation)
class AdminNotificationsController extends GetxController {
  FCMService get _fcm => Get.find<FCMService>();

  List<PushNotification> get allNotifications => _fcm.notifications.toList();

  /// Clarification responses from requestors — admin needs to review.
  List<PushNotification> get clarifications => _fcm.notifications
      .where(
        (n) => n.eventType == NotificationEventType.clarificationResponded,
      )
      .toList();

  /// Expense decisions (approved/rejected) triggered notifications.
  List<PushNotification> get decisions => _fcm.notifications
      .where(
        (n) => [
          NotificationEventType.expenseApproved,
          NotificationEventType.expenseRejected,
          NotificationEventType.clarificationRequired,
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
