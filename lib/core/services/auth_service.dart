import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../utils/widgets/logout_progress_overlay.dart';
import 'fcm_service.dart';
import 'storage_service.dart';
import '../../routes/app_routes.dart'; // Added import

class AuthService extends GetxService {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  final Rx<User?> currentUser = Rx<User?>(null);
  bool get isLoggedIn => currentUser.value != null;

  final RxBool isSessionVerified = false.obs;

  /// Guards the "Logging out…" indicator so it's shown at most once even if
  /// [logout] is triggered concurrently (e.g. a tap plus a 401 auto-logout).
  bool _logoutOverlayShown = false;

  AuthService(this._authRepository, this._storageService);

  Future<AuthService> init() async {
    isSessionVerified.value = false; // Always false on app start
    String? token = await _storageService.read('auth_token');

    // Migrate away from the legacy "session_<id>" placeholder token that the
    // old login flow wrote when the backend didn't return a JWT. Those strings
    // can never authenticate against the API, so drop them before any request
    // goes out and fires a spurious 401 → force-logout loop.
    if (token != null && token.startsWith('session_')) {
      await _storageService.delete('auth_token');
      token = null;
    }

    if (token != null) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        // Register FCM token on app start if logged in
        if (Get.isRegistered<FCMService>()) {
          Get.find<FCMService>().registerToken();
        }
      } else {
        await logout();
      }
    }
    return this;
  }

  void verifySession() {
    isSessionVerified.value = true;
  }

  Future<void> login(String email, String password) async {
    final result = await _authRepository.login(email, password);
    final user = result['user'] as User;
    final token = result['token'] as String?;

    if (token == null || token.isEmpty) {
      // Reject logins without a real token — never fabricate a session identifier.
      throw Exception('Login failed: server did not return an authentication token.');
    }

    currentUser.value = user;
    verifySession(); // Login explicitly verifies session
    await _storageService.write('auth_token', token);

    // Register FCM token after successful login
    if (Get.isRegistered<FCMService>()) {
      await Get.find<FCMService>().registerToken();
    }
  }

  Future<void> logout() async {
    // Immediately surface a blocking "Logging out…" indicator so the tap has
    // instant feedback while the network calls below run.
    _showLoggingOutOverlay();

    // Best-effort: unregister FCM token before clearing auth state
    if (Get.isRegistered<FCMService>()) {
      await Get.find<FCMService>().unregisterToken();
    }

    try {
      await _authRepository.logout();
    } catch (e) {
      if (kDebugMode) debugPrint('Logout error: $e');
    }

    currentUser.value = null;
    isSessionVerified.value = false;
    await _storageService.delete('auth_token');

    // Remove the indicator right before navigating so it doesn't linger on
    // top of the login screen.
    _hideLoggingOutOverlay();

    // Force clear all GetX controllers and state. Skip the navigation
    // if we're already on the login route — calling Get.offAllNamed
    // repeatedly to the same route causes the screen to rebuild and
    // replay its entrance animations (visible as a zigzag flash).
    if (Get.context != null && Get.currentRoute != AppRoutes.LOGIN) {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  // ── Logout indicator ─────────────────────────────────────────────────────

  void _showLoggingOutOverlay() {
    if (_logoutOverlayShown || Get.context == null) return;
    _logoutOverlayShown = true;
    // The overlay paints its own scrim, so keep the dialog barrier transparent
    // to avoid a doubled dim. Non-dismissible: the user can't cancel mid-logout.
    Get.dialog(
      const LogoutProgressOverlay(),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );
  }

  void _hideLoggingOutOverlay() {
    if (!_logoutOverlayShown) return;
    _logoutOverlayShown = false;
    if (Get.isDialogOpen ?? false) Get.back();
  }
}
