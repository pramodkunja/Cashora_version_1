import 'package:flutter/foundation.dart';
import '../../../../utils/app_text.dart';

/// Parsing helpers for the Admin Request Details screen. These look up
/// values across the many shapes the backend may return for the same
/// piece of data (flat keys, snake_case, nested objects, etc.).
class AdminRequestDetailsHelpers {
  AdminRequestDetailsHelpers._();

  /// Best-effort extraction of the requestor's department from a request
  /// payload — falls back to "General".
  static String getDepartment(Map<dynamic, dynamic> item) {
    // 1. Check top-level
    if (item['department'] != null && item['department'].toString().isNotEmpty) {
      return item['department'].toString();
    }
    if (item['department_name'] != null &&
        item['department_name'].toString().isNotEmpty) {
      return item['department_name'].toString();
    }

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

    // 4. Return reasonable default
    return 'General';
  }

  /// Best-effort extraction of the requestor's display name from a
  /// request payload. Falls back to [AppText.unknownUser].
  static String getUserName(Map<dynamic, dynamic> item) {
    String s(dynamic v) => v?.toString().trim() ?? '';
    bool ok(String v) => v.isNotEmpty && v.toLowerCase() != 'null';

    // ── 1. Direct flat keys backend may send ─────────────────────────
    for (final k in const [
      'user_name',
      'employee_name',
      'requestor_name',
      'submitted_by_name',
      'created_by_name',
      'requested_by_name',
      'full_name',
      'name',
    ]) {
      final v = s(item[k]);
      if (ok(v)) return v;
    }

    // ── 2. Flat first_name / last_name pair (denormalized backends) ──
    final flatFirst = s(item['first_name']);
    final flatLast = s(item['last_name']);
    if (ok(flatFirst)) return '$flatFirst $flatLast'.trim();

    // ── 3. Nested objects in priority order ──────────────────────────
    for (final k in const [
      'requestor',
      'user',
      'employee',
      'created_by',
      'submitted_by',
      'requested_by',
      'submitter',
    ]) {
      final raw = item[k];
      if (raw == null) continue;
      if (raw is String && ok(raw)) return raw;
      if (raw is Map) {
        // Best-name lookup inside the nested object.
        for (final sub in const ['name', 'full_name', 'display_name']) {
          final v = s(raw[sub]);
          if (ok(v)) return v;
        }
        final f = s(raw['first_name']);
        final l = s(raw['last_name']);
        if (ok(f)) return '$f $l'.trim();
        final email = s(raw['email']);
        if (ok(email)) return email.split('@').first;
      }
    }

    // ── 4. Bare email at top level ───────────────────────────────────
    final email = s(item['email']);
    if (ok(email)) return email.split('@').first;

    // ── Debug aid: surface the keys backend actually sent so the team
    //    can tell us which one carries the name. Logged once per call.
    debugPrint(
      '[admin_request_details] requestor name not found — keys=${item.keys.toList()}',
    );
    return AppText.unknownUser;
  }

  /// snake_case / lower-case category enum → display (e.g.
  /// "office_supplies" → "Office Supplies", "pre_approved" → "Pre Approved").
  static String prettyCategory(String raw) {
    if (raw.isEmpty) return '';
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
