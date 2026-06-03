import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/repositories/notification_repository.dart';
import '../../modules/notifications/data/notification_model.dart';
import '../../routes/app_routes.dart';
import '../../core/services/auth_service.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main(). Nothing else needed here.
  if (kDebugMode) debugPrint('[FCM] Background message: ${message.messageId}');
}

/// FCMService handles all Firebase Cloud Messaging lifecycle events:
///
/// 1. Permission request (iOS)
/// 2. Token capture + backend registration
/// 3. Token refresh → re-registration
/// 4. Foreground message → in-app local notification + adds to list
/// 5. Background/terminated tap → routes to expense detail
class FCMService extends GetxService {
  final NotificationRepository _notificationRepository;

  FCMService(this._notificationRepository);

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Observable list of all received push notifications (newest first).
  final RxList<PushNotification> notifications = <PushNotification>[].obs;

  /// The current FCM device token (nullable until obtained).
  String? _currentToken;

  // ── Android notification channel ────────────────────────────────────────
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'cashora_push_channel',
    'Cashora Notifications',
    description: 'Push notifications for expense updates',
    importance: Importance.high,
  );

  // ── Init ────────────────────────────────────────────────────────────────

  Future<FCMService> init() async {
    if (!kIsWeb) {
      await _setupLocalNotifications();
      await _requestPermission();
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      _setupForegroundHandler();
      _setupTapHandler();
    }
    return this;
  }

  Future<void> _setupLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create the high-importance channel on Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Keep foreground notifications visible on iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _requestPermission() async {
    // 1. Firebase Messaging Permission (iOS/Web)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Android 13+ Permission (Runtime)
    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied || status.isLimited) {
        await Permission.notification.request();
      }
    }

    final authed =
        settings.authorizationStatus == AuthorizationStatus.authorized;
    _logBanner(
      'PERMISSION',
      '${settings.authorizationStatus}'
          '${authed ? "  ✅" : "  ❌ (OS will not deliver push — enable in Settings → Apps → Cashora → Notifications)"}',
    );
  }

  // ── Token management ────────────────────────────────────────────────────

  Future<void> registerToken() async {
    _logBanner('REGISTER TOKEN', 'starting…');

    // The app targets Android only. Web push needs a real VAPID key from
    // the Firebase console — without one, `PushManager.subscribe` throws
    // `InvalidAccessError`. Skip web cleanly so testing in Chrome doesn't
    // spam errors; pushes will work on the actual Android build.
    if (kIsWeb) {
      _logBanner(
        'SKIP (WEB)',
        'web push needs a VAPID key from Firebase Console → Cloud Messaging → Web Push certificates. '
            'Run on an Android device/emulator to test FCM end-to-end.',
      );
      return;
    }

    try {
      String? token;
      if (Platform.isIOS) {
        final apns = await _messaging.getAPNSToken();
        _logBanner('APNS TOKEN', apns ?? '(null — iOS push will fail)');
      }
      token = await _messaging.getToken();

      if (token == null) {
        _logBanner(
          'TOKEN',
          '❌ NULL — usually means Google Play Services missing on this device/emulator',
        );
        return;
      }

      _currentToken = token;
      _logBanner('TOKEN CAPTURED', token);

      await _registerWithBackend(token);

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) async {
        _logBanner('TOKEN REFRESHED', newToken);
        _currentToken = newToken;
        await _registerWithBackend(newToken);
      });
    } catch (e) {
      _logBanner('REGISTER TOKEN ERROR', e.toString());
    }
  }

  Future<void> _registerWithBackend(String token) async {
    // Backend DevicePlatform enum: 'android' | 'ios' | 'web'
    String platform = 'web';
    if (!kIsWeb) {
      platform = Platform.isAndroid ? 'android' : 'ios';
    }

    // Pull the real app version from the bundle (was hardcoded '1.0.0').
    String appVersion = '1.0.0';
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) appVersion = info.version;
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] PackageInfo failed: $e');
    }

    _logBanner(
      'BACKEND POST',
      '/notifications/devices/register  platform=$platform  version=$appVersion',
    );

    // Retry once on failure (per backend guide)
    bool success = await _notificationRepository.registerToken(
      token: token,
      platform: platform,
      appVersion: appVersion,
    );

    if (!success) {
      _logBanner('BACKEND REGISTER', '⚠️  first attempt failed, retrying in 2s…');
      await Future.delayed(const Duration(seconds: 2));
      success = await _notificationRepository.registerToken(
        token: token,
        platform: platform,
        appVersion: appVersion,
      );
    }

    _logBanner(
      'BACKEND REGISTER',
      success
          ? '✅ device registered with backend — pushes will arrive'
          : '❌ backend rejected token — check that POST /notifications/devices/register exists and returns {"success": true}',
    );
  }

  /// Prints a single highly-visible diagnostic line so the FCM lifecycle is
  /// easy to read in `flutter run` output.
  void _logBanner(String tag, String detail) {
    if (!kDebugMode) return;
    debugPrint('━━━━━━━ [FCM ▸ $tag] $detail');
  }

  /// Call this on logout — best-effort, never blocks logout flow.
  Future<void> unregisterToken() async {
    if (_currentToken == null) return;
    try {
      await _notificationRepository.unregisterToken(_currentToken!);
      if (kDebugMode) debugPrint('[FCM] Token unregistered from backend');
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Unregister error (ignored): $e');
    }
    _currentToken = null;
  }

  // ── Message handlers ────────────────────────────────────────────────────

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('[FCM] Foreground message: ${message.messageId}');
      }

      final notification = _buildPushNotification(message);
      if (notification != null) {
        notifications.insert(0, notification);
        _showLocalNotification(message);
      }
    });
  }

  void _setupTapHandler() {
    // App opened from background via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) debugPrint('[FCM] Notification tapped (background)');
      _handleTap(message.data);
    });

    // App launched from terminated state via notification tap
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        if (kDebugMode) debugPrint('[FCM] Initial message (terminated)');
        // Delay to let navigation stack settle
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleTap(message.data);
        });
      }
    });
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    // Payload is the JSON-encoded data map
    if (response.payload != null) {
      try {
        final data = Map<String, dynamic>.from(
          Uri.splitQueryString(response.payload!),
        );
        _handleTap(data);
      } catch (_) {}
    }
  }

  // ── Navigation on tap ───────────────────────────────────────────────────

  void _handleTap(Map<String, dynamic> data) {
    final eventType = NotificationEventTypeX.fromString(data['event_type']);
    final expenseId = data['expense_id'];
    final requestId = data['request_id'];

    final bool isExpenseEvent = [
      NotificationEventType.expenseApproved,
      NotificationEventType.expenseRejected,
      NotificationEventType.clarificationRequired,
      NotificationEventType.clarificationResponded,
      NotificationEventType.expensePaid,
    ].contains(eventType);

    if (!isExpenseEvent) return;

    // Determine route based on logged-in user's role
    final authService = Get.find<AuthService>();
    final role = authService.currentUser.value?.role.toLowerCase() ?? '';

    final args = <String, dynamic>{
      'expense_id': expenseId,
      'request_id': requestId,
      'from_notification': true,
    };

    if (role == 'admin' || role == 'super_admin') {
      Get.toNamed(AppRoutes.ADMIN_REQUEST_DETAILS, arguments: args);
    } else if (role == 'accountant') {
      Get.toNamed(
        AppRoutes.ACCOUNTANT_PAYMENT_REQUEST_DETAILS,
        arguments: args,
      );
    } else {
      // Requestor
      Get.toNamed(AppRoutes.REQUEST_DETAILS_READ, arguments: args);
    }
  }

  // ── Local notification display ──────────────────────────────────────────

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? 'Cashora';
    final body = notification.body ?? '';
    final payload = _dataToQueryString(message.data);

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  PushNotification? _buildPushNotification(RemoteMessage message) {
    final title =
        message.notification?.title ??
        message.data['event_type'] ??
        'Notification';
    final body = message.notification?.body ?? '';
    return PushNotification.fromFCM(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      data: message.data,
    );
  }

  String _dataToQueryString(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  /// Expose unread count for badge indicators in app bars / nav bars.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Mark a single notification as read.
  void markRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifications.refresh();
    }
  }

  /// Mark all notifications as read.
  void markAllRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  /// Clear all notifications from the in-memory list.
  void clearAll() {
    notifications.clear();
  }

  // ── DEBUG / TEST HELPERS (debug mode only) ──────────────────────────────

  /// Inject a fake push notification to test the UI without a real backend.
  /// Call this from any debug button in the app.
  ///
  /// Example:
  ///   Get.find<FCMService>().injectTestNotification(
  ///     eventType: 'expense_approved',
  ///     expenseId: 'EXP-1001',
  ///   );
  void injectTestNotification({
    required String eventType,
    String? expenseId,
    String? requestId,
    String? title,
    String? body,
  }) {
    assert(
      kDebugMode,
      'injectTestNotification() must only be called in debug mode',
    );

    final titles = {
      'expense_approved': 'Expense Update',
      'expense_rejected': 'Expense Update',
      'clarification_required': 'Clarification Required',
      'clarification_responded': 'Clarification Responded',
      'expense_paid': 'Expense Paid',
    };

    final bodies = {
      'expense_approved':
          'Your expense ${expenseId ?? 'EXP-1001'} was approved.',
      'expense_rejected':
          'Your expense ${expenseId ?? 'EXP-1001'} was rejected.',
      'clarification_required':
          'Your expense ${expenseId ?? 'EXP-1001'} needs clarification.',
      'clarification_responded':
          'Requester responded for expense ${expenseId ?? 'EXP-1001'}.',
      'expense_paid':
          'Your expense ${expenseId ?? 'EXP-1001'} has been marked as paid.',
    };

    final notification = PushNotification.fromFCM(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? titles[eventType] ?? 'Notification',
      body: body ?? bodies[eventType] ?? '',
      data: {
        'event_type': eventType,
        'expense_id': expenseId ?? 'EXP-1001',
        'request_id': requestId ?? 'REQ-001',
        'status': eventType,
      },
    );

    notifications.insert(0, notification);

    if (kDebugMode) {
      debugPrint('[FCM TEST] Injected: $eventType → ${notification.title}');
    }
  }
}
