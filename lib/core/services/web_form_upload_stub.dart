// Non-web stub — this file is selected by the conditional export
// when NOT on web (i.e. dart.library.html is unavailable).
// The kIsWeb guard in request_repository.dart means this is never called.
import 'dart:async';

Future<Map<String, dynamic>> webMultipartPost({
  required String url,
  required String token,
  required Map<String, String> fields,
  List<Map<String, dynamic>> files = const [],
}) {
  throw UnsupportedError(
    'webMultipartPost is only available on Flutter Web. '
    'Use Dio FormData on native platforms instead.',
  );
}
