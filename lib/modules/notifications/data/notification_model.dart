import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';

/// Maps backend `event_type` strings to strongly-typed enum values.
enum NotificationEventType {
  expenseApproved,
  expenseRejected,
  clarificationRequired,
  clarificationResponded,
  expensePaid,
  unknown,
}

extension NotificationEventTypeX on NotificationEventType {
  static NotificationEventType fromString(String? value) {
    switch (value) {
      case 'expense_approved':
        return NotificationEventType.expenseApproved;
      case 'expense_rejected':
        return NotificationEventType.expenseRejected;
      case 'clarification_required':
        return NotificationEventType.clarificationRequired;
      case 'clarification_responded':
        return NotificationEventType.clarificationResponded;
      case 'expense_paid':
        return NotificationEventType.expensePaid;
      default:
        return NotificationEventType.unknown;
    }
  }

  String get label {
    switch (this) {
      case NotificationEventType.expenseApproved:
        return 'Approved';
      case NotificationEventType.expenseRejected:
        return 'Rejected';
      case NotificationEventType.clarificationRequired:
        return 'Clarification Required';
      case NotificationEventType.clarificationResponded:
        return 'Clarification Responded';
      case NotificationEventType.expensePaid:
        return 'Paid';
      case NotificationEventType.unknown:
        return 'Notification';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationEventType.expenseApproved:
        return Icons.check_circle_outline_rounded;
      case NotificationEventType.expenseRejected:
        return Icons.cancel_outlined;
      case NotificationEventType.clarificationRequired:
        return Icons.help_outline_rounded;
      case NotificationEventType.clarificationResponded:
        return Icons.reply_rounded;
      case NotificationEventType.expensePaid:
        return Icons.payments_outlined;
      case NotificationEventType.unknown:
        return Icons.notifications_outlined;
    }
  }

  Color get iconColor {
    switch (this) {
      case NotificationEventType.expenseApproved:
        return const Color(0xFF16A34A);
      case NotificationEventType.expenseRejected:
        return const Color(0xFFEF4444);
      case NotificationEventType.clarificationRequired:
        return const Color(0xFFF59E0B);
      case NotificationEventType.clarificationResponded:
        return const Color(0xFF3B82F6);
      case NotificationEventType.expensePaid:
        return const Color(0xFF7C3AED);
      case NotificationEventType.unknown:
        return AppColors.textSlate;
    }
  }

  Color get iconBg {
    switch (this) {
      case NotificationEventType.expenseApproved:
        return const Color(0xFFDCFCE7);
      case NotificationEventType.expenseRejected:
        return const Color(0xFFFEE2E2);
      case NotificationEventType.clarificationRequired:
        return const Color(0xFFFEF3C7);
      case NotificationEventType.clarificationResponded:
        return const Color(0xFFDBEAFE);
      case NotificationEventType.expensePaid:
        return const Color(0xFFEDE9FE);
      case NotificationEventType.unknown:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get badgeColor {
    switch (this) {
      case NotificationEventType.expenseApproved:
        return const Color(0xFF16A34A);
      case NotificationEventType.expenseRejected:
        return const Color(0xFFEF4444);
      case NotificationEventType.clarificationRequired:
        return const Color(0xFFF59E0B);
      case NotificationEventType.clarificationResponded:
        return const Color(0xFF3B82F6);
      case NotificationEventType.expensePaid:
        return const Color(0xFF7C3AED);
      case NotificationEventType.unknown:
        return AppColors.textSlate;
    }
  }

  Color get badgeBg {
    return iconBg;
  }
}

/// Represents a push notification received from the backend FCM system.
class PushNotification {
  final String id;
  final String title;
  final String body;
  final NotificationEventType eventType;
  final String? expenseId;
  final String? requestId;
  final String? status;
  final DateTime receivedAt;
  bool isRead;

  PushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.eventType,
    this.expenseId,
    this.requestId,
    this.status,
    required this.receivedAt,
    this.isRead = false,
  });

  /// Construct from FCM RemoteMessage data map and notification fields.
  factory PushNotification.fromFCM({
    required String id,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    return PushNotification(
      id: id,
      title: title,
      body: body,
      eventType: NotificationEventTypeX.fromString(data['event_type']),
      expenseId: data['expense_id'],
      requestId: data['request_id'],
      status: data['status'],
      receivedAt: DateTime.now(),
    );
  }

  /// Returns the expense reference string (e.g. "EXP-1001") for display.
  String? get expenseRef {
    if (expenseId != null) return expenseId;
    if (requestId != null) return requestId;
    return null;
  }

  /// Human-readable relative time since received.
  String get timeAgo {
    final diff = DateTime.now().difference(receivedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
