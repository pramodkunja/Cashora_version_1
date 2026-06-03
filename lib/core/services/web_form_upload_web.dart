// Web implementation — selected by conditional export when dart.library.html
// is available (Flutter Web). Uses the browser's native XMLHttpRequest +
// FormData, bypassing Dio's BrowserHttpClientAdapter which doesn't correctly
// serialize file bytes in multipart requests.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Returns a MIME type string based on the file extension.
String _mimeType(String filename) {
  final ext = filename.split('.').last.toLowerCase();
  const map = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'heic': 'image/heic',
    'pdf': 'application/pdf',
  };
  return map[ext] ?? 'application/octet-stream';
}

/// POST multipart/form-data using the browser's native XHR + FormData.
/// [files] entries must have keys: 'key' (String), 'bytes' (List<int>),
/// 'filename' (String).
Future<Map<String, dynamic>> webMultipartPost({
  required String url,
  required String token,
  required Map<String, String> fields,
  List<Map<String, dynamic>> files = const [],
}) async {
  final nativeFormData = html.FormData();

  // Append all text fields
  fields.forEach((key, value) {
    nativeFormData.append(key, value);
  });

  // Append all file blobs with correct MIME type
  for (final entry in files) {
    final bytes = entry['bytes'] as List<int>;
    final filename = entry['filename'] as String;
    final fieldKey = entry['key'] as String;
    final mime = _mimeType(filename);
    // Blob with explicit MIME type — FastAPI validates this
    final blob = html.Blob([bytes], mime);
    nativeFormData.appendBlob(fieldKey, blob, filename);
    if (kDebugMode) {
      debugPrint('Appended file: key=$fieldKey, filename=$filename, '
        'bytes=${bytes.length}, mime=$mime');
    }
  }

  final completer = Completer<Map<String, dynamic>>();
  final xhr = html.HttpRequest();
  xhr.open('POST', url);
  xhr.setRequestHeader('Authorization', 'Bearer $token');

  xhr.onLoad.listen((_) {
    final status = xhr.status ?? 0;
    final body = xhr.responseText ?? '';
    if (kDebugMode) debugPrint('XHR response: status=$status');
    if (status >= 200 && status < 300) {
      try {
        final decoded = json.decode(body);
        completer.complete(decoded as Map<String, dynamic>);
      } catch (e) {
        completer.completeError(Exception('JSON parse error: $e'));
      }
    } else {
      // Print the full error body so we can see FastAPI's validation message
      if (kDebugMode) debugPrint('Server error $status: $body');
      completer.completeError(
        Exception('HTTP $status: $body'),
      );
    }
  });

  xhr.onError.listen((_) {
    completer.completeError(Exception('XHR network error during upload'));
  });

  if (kDebugMode) {
    debugPrint('Sending XHR to $url with ${fields.length} fields, '
      '${files.length} files...');
  }
  xhr.send(nativeFormData);
  return completer.future;
}

