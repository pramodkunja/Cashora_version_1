import 'package:flutter/material.dart';

enum NotificationType {
  actionRequired,
  approved,
  rejected,
  info,
  payment,
  newRequest,
  clarification,
  update,
  video, // For potential future use
}

class NotificationItem {
  final String id;
  final String title;
  final String time;
  final NotificationType type;
  final String? ref;
  final String? body;
  final String? amount;
  final String? image; // Avatar url
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBg;
  final bool isUrgent;
  final bool isUnread;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeBg;

  NotificationItem({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
    this.ref,
    this.body,
    this.amount,
    this.image,
    this.icon,
    this.iconColor,
    this.iconBg,
    this.isUrgent = false,
    this.isUnread = false,
    this.badgeText,
    this.badgeColor,
    this.badgeBg,
  });
}
