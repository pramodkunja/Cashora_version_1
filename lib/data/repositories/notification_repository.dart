import 'package:flutter/foundation.dart';
import '../../core/services/network_service.dart';

/// Repository for device token registration/unregistration with the backend.
///
/// Endpoints (from backend guide):
///   POST /notifications/devices/register
///   POST /notifications/devices/unregister
class NotificationRepository {
  final NetworkService _networkService;

  NotificationRepository(this._networkService);

  /// Register a device FCM token with the backend.
  ///
  /// [token]      FCM registration token from FirebaseMessaging.
  /// [platform]   'android' or 'ios'.
  /// [appVersion] Optional app version string (e.g. '1.0.0').
  ///
  /// Backend contract:
  ///   POST /notifications/devices/register
  ///   Body: { "token": string, "platform": string, "app_version": string? }
  ///   200: { "success": true, "message": "Device token registered successfully." }
  Future<bool> registerToken({
    required String token,
    required String platform,
    String? appVersion,
  }) async {
    try {
      final response = await _networkService.post(
        '/notifications/devices/register',
        data: {
          'token': token,
          'platform': platform,
          'app_version': appVersion,
        },
      );
      final data = response.data;
      return data is Map && data['success'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationRepository] registerToken error: $e');
      return false;
    }
  }

  /// Unregister a device FCM token from the backend (called on logout).
  ///
  /// Backend contract:
  ///   POST /notifications/devices/unregister
  ///   Body: { "token": string }
  ///   200: { "success": true, "message": "Device token unregistered successfully." }
  Future<bool> unregisterToken(String token) async {
    try {
      final response = await _networkService.post(
        '/notifications/devices/unregister',
        data: {'token': token},
      );
      final data = response.data;
      return data is Map && data['success'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationRepository] unregisterToken error: $e');
      // Per backend guide: continue logout even if this fails
      return false;
    }
  }
}
