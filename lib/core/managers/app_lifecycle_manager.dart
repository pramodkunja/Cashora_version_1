import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../../modules/lock/views/lock_view.dart';

class AppLifecycleManager extends GetxService with WidgetsBindingObserver {
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // User requested "Fresh Start" lock only. Disabling Resume lock.
    /*
    if (state == AppLifecycleState.resumed) {
      _checkAndLock();
    }
    */
  }

  Future<void> _checkAndLock() async {
    // 1. Check if user is logged in
    if (!_authService.isLoggedIn) return;

    // 2. Check if Face ID is enabled
    String? enabled = await _storage.read('face_id_enabled');
    if (enabled == 'true') {
      // 3. Navigate to Lock Screen
      // Check if already locked to prevent stacking?
      if (Get.currentRoute != '/lock') {
        // We need to define this route or just use class
        // Using Get.to(() => LockView()) pushes it.
        // To avoid duplicates, we can check.
        // A simple way is to use a flag or check if top route is LockView.
        // Since we don't have named route for LockView yet, we can push it.

        Get.to(
          () => const LockView(),
          transition: Transition.noTransition,
          fullscreenDialog: true,
        );
      }
    }
  }
}
