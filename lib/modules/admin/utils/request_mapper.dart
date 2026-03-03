import 'package:flutter/material.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_colors.dart';

class RequestMapper {
  /// Extracts the Department Name from various nested possibilities
  static String getDepartment(Map<String, dynamic> item) {
    // 1. Check top-level
    if (item['department'] != null && item['department'].toString().isNotEmpty)
      return item['department'].toString();
    if (item['department_name'] != null &&
        item['department_name'].toString().isNotEmpty)
      return item['department_name'].toString();

    // 2. Check nested 'requestor'
    if (item['requestor'] != null && item['requestor'] is Map) {
      final r = item['requestor'];
      if (r['department'] != null) return r['department'].toString();
      if (r['department_name'] != null) return r['department_name'].toString();
    }

    // 3. Check nested 'user'
    if (item['user'] != null && item['user'] is Map) {
      final u = item['user'];
      if (u['department'] != null) return u['department'].toString();
    }

    return 'General';
  }

  /// Extracts the User Name from various nested possibilities
  static String getUserName(Map<String, dynamic> item) {
    // Check specific keys first
    if (item['user_name'] != null && item['user_name'].toString().isNotEmpty)
      return item['user_name'].toString();
    if (item['employee_name'] != null &&
        item['employee_name'].toString().isNotEmpty)
      return item['employee_name'].toString();

    // Check nested 'requestor' object (Primary)
    if (item['requestor'] != null) {
      if (item['requestor'] is Map) {
        final r = item['requestor'];
        final String firstName = r['first_name']?.toString() ?? '';
        final String lastName = r['last_name']?.toString() ?? '';
        if (firstName.isNotEmpty) {
          return "$firstName $lastName".trim();
        }
        if (r['email'] != null) return r['email'].toString().split('@').first;
      }
    }

    if (item['requestor_name'] != null &&
        item['requestor_name'].toString().isNotEmpty)
      return item['requestor_name'].toString();

    // Check nested 'user' object
    if (item['user'] != null) {
      if (item['user'] is Map) {
        final u = item['user'];
        if (u['name'] != null) return u['name'].toString();
        if (u['full_name'] != null) return u['full_name'].toString();
        if (u['first_name'] != null)
          return "${u['first_name']} ${u['last_name'] ?? ''}".trim();
        if (u['email'] != null) return u['email'].toString().split('@').first;
      } else if (item['user'] is String) {
        return item['user'];
      }
    }

    // Check nested 'employee' object
    if (item['employee'] != null) {
      if (item['employee'] is Map) {
        return item['employee']['name']?.toString() ??
            item['employee']['first_name']?.toString() ??
            'Unknown';
      } else if (item['employee'] is String) {
        return item['employee'];
      }
    }

    return AppText.unknownUser;
  }

  /// Formats the date string into a readable format (e.g., "Jan 12")
  static String formatDate(dynamic rawDate) {
    String dateStr = rawDate?.toString() ?? '';
    if (dateStr.isEmpty) return AppText.noDate;

    try {
      final DateTime dt = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      if (dateStr.contains('T')) return dateStr.split('T')[0];
      return dateStr;
    }
  }

  /// Returns user initials
  static String getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  /// Returns status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'auto_approved':
        return AppColors.successGreen;
      case 'rejected':
        return AppColors.error;
      case 'clarification_required':
        return Colors.orange;
      case 'paid':
        return Colors.purple;
      default:
        return const Color(0xFFF59E0B); // Pending Orange/Amber
    }
  }
}
