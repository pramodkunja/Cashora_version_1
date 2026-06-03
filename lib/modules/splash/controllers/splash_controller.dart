import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthService _authService = Get.find<AuthService>();

  /// Drives the bottom progress bar in [SplashView]. Updated in checkpoints
  /// coordinated with the view's reveal choreography so the bar fills
  /// alongside the brand animation instead of finishing early.
  final RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _runSplashSequence();
  }

  /// Total wall-clock time on splash ≈ 2600 ms — matches the view's animation
  /// (2400 ms) plus a brief hold so the completed progress bar is visible
  /// before we navigate away.
  Future<void> _runSplashSequence() async {
    await Future.delayed(const Duration(milliseconds: 600));
    progress.value = 0.30;

    await Future.delayed(const Duration(milliseconds: 900));
    progress.value = 0.75;

    await Future.delayed(const Duration(milliseconds: 700));
    progress.value = 1.0;

    await Future.delayed(const Duration(milliseconds: 400));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    if (!_authService.isLoggedIn) {
      Get.offAllNamed(AppRoutes.LOGIN);
      return;
    }

    // User has a valid token + user session restored from storage.
    final storage = Get.find<StorageService>();
    final bioEnabled = await storage.read('face_id_enabled');

    if (bioEnabled == 'true') {
      Get.offAllNamed(AppRoutes.LOCK);
    } else {
      _authService.verifySession();
      _routeToDashboard();
    }
  }

  void _routeToDashboard() {
    final user = _authService.currentUser.value;
    if (user == null) {
      Get.offAllNamed(AppRoutes.LOGIN);
      return;
    }

    final role = user.role.toLowerCase().trim();
    if (role == 'admin' || role == 'super_admin') {
      Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
    } else if (role == 'accountant') {
      Get.offAllNamed(AppRoutes.ACCOUNTANT_DASHBOARD);
    } else if (role == 'requestor') {
      Get.offAllNamed(AppRoutes.REQUESTOR);
    } else {
      // Unknown role — force login
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
