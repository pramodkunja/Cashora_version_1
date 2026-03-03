// Conditional export: uses dart:html (XHR) on web, throws on native.
// This pattern allows both web and native to compile cleanly.
export 'web_form_upload_stub.dart'
    if (dart.library.html) 'web_form_upload_web.dart';
