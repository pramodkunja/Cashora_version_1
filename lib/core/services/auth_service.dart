import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'storage_service.dart';
import '../../routes/app_routes.dart'; // Added import

class AuthService extends GetxService {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  final Rx<User?> currentUser = Rx<User?>(null);
  bool get isLoggedIn => currentUser.value != null;

  final RxBool isSessionVerified = false.obs;

  AuthService(this._authRepository, this._storageService);

  Future<AuthService> init() async {
    isSessionVerified.value = false; // Always false on app start
    String? token = await _storageService.read('auth_token');
    if (token != null) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        // Do NOT set isSessionVerified to true automatically on init
        // It must be verified via Biometric or Login
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

    currentUser.value = user;
    verifySession(); // Login explicitly verifies session

    if (token != null) {
      await _storageService.write('auth_token', token);
    } else {
      // Fallback to session token if no token provided
      await _storageService.write('auth_token', 'session_${user.id}');
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      print('Logout error: $e'); // Log but continue local cleanup
    }

    currentUser.value = null;
    isSessionVerified.value = false;
    await _storageService.delete('auth_token');

    // Force clear all GetX controllers and state
    if (Get.context != null) {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
