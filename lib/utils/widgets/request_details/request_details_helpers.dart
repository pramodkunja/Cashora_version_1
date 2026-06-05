// Data-extraction helpers used across the shared request details
// layout. All of these tolerate the various backend shapes we've
// observed for the same conceptual field.

/// Convert a snake_case / space-delimited enum key to a Title Case
/// display label. `office_supplies` → `Office Supplies`.
String prettyEnumLabel(String raw) {
  if (raw.isEmpty) return '';
  return raw
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}

/// Two-letter initials for a person's name. Empty input returns "U".
/// Single-word names get their first letter only.
String initialsFor(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return 'U';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.elementAt(1)[0]).toUpperCase();
}

/// Best-effort name extraction tolerant of every backend shape we've
/// seen: flat `user_name` / `employee_name` / `requestor_name`, nested
/// `requestor` / `user` objects, email fallback.
String readUserName(Map<dynamic, dynamic> item) {
  if (item['user_name'] != null &&
      item['user_name'].toString().isNotEmpty) {
    return item['user_name'].toString();
  }
  if (item['employee_name'] != null &&
      item['employee_name'].toString().isNotEmpty) {
    return item['employee_name'].toString();
  }
  if (item['requestor'] is Map) {
    final r = item['requestor'];
    final fn = r['first_name']?.toString() ?? '';
    final ln = r['last_name']?.toString() ?? '';
    if (fn.isNotEmpty) return '$fn $ln'.trim();
    if (r['email'] != null) return r['email'].toString().split('@').first;
  }
  if (item['requestor_name'] != null &&
      item['requestor_name'].toString().isNotEmpty) {
    return item['requestor_name'].toString();
  }
  if (item['user'] is Map) {
    final u = item['user'];
    if (u['name'] != null) return u['name'].toString();
    if (u['full_name'] != null) return u['full_name'].toString();
    if (u['first_name'] != null) {
      return '${u['first_name']} ${u['last_name'] ?? ''}'.trim();
    }
    if (u['email'] != null) return u['email'].toString().split('@').first;
  }
  return 'Unknown user';
}

/// Best-effort department extraction. Falls back to "General" if the
/// backend hasn't populated any of the common keys.
String readDepartment(Map<dynamic, dynamic> item) {
  final direct = item['department'] ?? item['department_name'];
  if (direct != null && direct.toString().isNotEmpty) {
    return direct.toString();
  }
  if (item['requestor'] is Map) {
    final r = item['requestor'];
    final v = r['department'] ?? r['department_name'];
    if (v != null && v.toString().isNotEmpty) return v.toString();
  }
  if (item['user'] is Map) {
    final u = item['user'];
    if (u['department'] != null) return u['department'].toString();
  }
  return 'General';
}

/// Walk the request map and assemble a de-duped list of attachment
/// descriptors `{name, url, file}`. Covers the bundled `attachments[]`
/// list AND legacy single-key fields (`receipt_url`, `payment_qr_url`,
/// `bill_url`, `bill_urls`).
List<Map<String, dynamic>> collectAttachments(Map<dynamic, dynamic> req) {
  final out = <Map<String, dynamic>>[];
  final seen = <String>{};
  void add(String name, dynamic url) {
    if (url == null) return;
    final s = url.toString();
    if (s.isEmpty || !seen.add(s)) return;
    out.add({'name': name, 'url': s, 'file': s});
  }

  if (req['attachments'] is List) {
    for (final raw in (req['attachments'] as List)) {
      if (raw is Map) {
        add(
          raw['name']?.toString() ?? 'Attachment',
          raw['url'] ?? raw['file'] ?? raw['file_url'],
        );
      }
    }
  }
  add('Receipt', req['receipt_url']);
  add('QR Code', req['payment_qr_url'] ?? req['qr_url']);
  if (req['bill_urls'] is List) {
    final bills = req['bill_urls'] as List;
    for (int i = 0; i < bills.length; i++) {
      add(bills.length > 1 ? 'Bill ${i + 1}' : 'Bill', bills[i]);
    }
  } else if (req['bill_url'] != null) {
    add('Bill', req['bill_url']);
  }
  return out;
}
