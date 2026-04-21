import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthService _authService = Get.find<AuthService>();

  final int splashDuration = 8000;
  final RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startLoading();
  }

  void _startLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));
    progress.value = 0.3;

    await Future.delayed(const Duration(milliseconds: 1000));
    progress.value = 0.8;

    await Future.delayed(const Duration(milliseconds: 500));
    progress.value = 1.0;

    Future.delayed(const Duration(milliseconds: 500), () {
      _navigateToNextScreen();
    });
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
      // Biometric lock — user must unlock before accessing the app.
      Get.offAllNamed(AppRoutes.LOCK);
    } else {
      // No biometric — session is already valid, go straight to dashboard.
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
