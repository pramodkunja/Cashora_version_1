class AppConfig {
  static const String appName = 'Cashora';

  // ==================== NETWORK CONFIGURATION ====================
  // Three named environment tiers: dev / staging / prod.
  //
  // Resolution order (first match wins):
  //   1. --dart-define=API_BASE_URL=https://...   (explicit per-build override)
  //   2. --dart-define=APP_ENV=<dev|staging|prod>  (named tier)
  //   3. Debug builds → dev tier; release/profile builds → prod tier.
  //
  // Examples:
  //   flutter run                                       # → dev tier
  //   flutter build apk --release                       # → prod tier
  //   flutter run --dart-define=APP_ENV=staging         # → staging tier
  //   flutter run --dart-define=API_BASE_URL=https://x  # → one-off override
  //
  // SECURITY NOTE: If you point the prod URL at a cleartext (http://) host,
  // [apiBaseUrl] will throw at app startup. Release builds must use HTTPS.
  // The Android side also enforces this — see
  // android/app/src/main/res/xml/network_security_config.xml. Keep both
  // files in sync if you change the dev LAN IP.
  // ===============================================================

  // dart.vm.product is true in release/profile, false in debug.
  static const bool kIsDebug = !bool.fromEnvironment('dart.vm.product');

  static const String _override = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: '',
  );

  // === Tier URLs ===
  // Developer LAN host. Plain HTTP — only reachable from on-LAN devices.
  // If your LAN IP changes, update BOTH this constant AND the matching entry
  // in android/app/src/main/res/xml/network_security_config.xml.
  static const String _devBaseUrl = 'http://192.168.0.149:8000';
  // Pre-prod environment. Replace with the real staging URL when stood up.
  static const String _stagingBaseUrl = 'https://cashora.nxsys.in';
  // Production — the URL real users hit.
  static const String _prodBaseUrl = 'https://cashora.nxsys.in';

  /// Active environment tier as a short string for logging / debug UI.
  /// Returns one of: `'dev'`, `'staging'`, `'prod'`, `'override'`.
  static String get environment {
    if (_override.isNotEmpty) return 'override';
    switch (_envName) {
      case 'dev':
        return 'dev';
      case 'staging':
        return 'staging';
      case 'prod':
        return 'prod';
    }
    return 'prod';
  }

  /// Resolved API base URL. Throws in release builds if the URL would be
  /// cleartext (http://) with no explicit override — that almost always
  /// means someone left a dev URL in [_prodBaseUrl].
  static String get apiBaseUrl {
    final url = _resolveUrl();
    if (!kIsDebug && _override.isEmpty && url.startsWith('http://')) {
      throw StateError(
        'AppConfig: release build resolved to a cleartext URL ($url). '
        'Production URLs must use https://. Fix _prodBaseUrl or pass '
        '--dart-define=API_BASE_URL=https://...',
      );
    }
    return url;
  }

  static String _resolveUrl() {
    if (_override.isNotEmpty) return _override;
    switch (_envName) {
      case 'dev':
        return _devBaseUrl;
      case 'staging':
        return _stagingBaseUrl;
      case 'prod':
        return _prodBaseUrl;
    }
    // Default: production for every build (debug + release). Devs who need
    // the LAN backend can opt in with --dart-define=APP_ENV=dev, and a
    // one-off URL can still be passed via --dart-define=API_BASE_URL=...
    return _prodBaseUrl;
  }

  // Timeouts (in milliseconds)
  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds

  // Debug mode - set to true to see detailed network logs
  static const bool enableDebugLogs = true;
}
