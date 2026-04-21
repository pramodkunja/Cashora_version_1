import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BiometricService extends GetxService {
  final LocalAuthentication _auth = LocalAuthentication();
  final RxBool isSupported = false.obs;
  final RxBool canUseBiometrics = false.obs;

  Future<BiometricService> init() async {
    // Biometrics are not available on web
    if (kIsWeb) {
      isSupported.value = false;
      canUseBiometrics.value = false;
      return this;
    }

    try {
      bool isDeviceSupported = await _auth.isDeviceSupported();
      bool canCheck = await _auth.canCheckBiometrics;

      isSupported.value = isDeviceSupported;
      canUseBiometrics.value = canCheck;
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('Error initializing biometrics: $e');
      isSupported.value = false;
      canUseBiometrics.value = false;
    } catch (e) {
      if (kDebugMode) debugPrint('Generic error init biometrics: $e');
      isSupported.value = false;
      canUseBiometrics.value = false;
    }
    return this;
  }

  Future<bool> authenticate() async {
    if (!isSupported.value || !canUseBiometrics.value) {
      if (kDebugMode) debugPrint('Biometrics not supported or available');
      return false;
    }

    try {
      // API fallback: minimal parameters
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('Authentication error: $e');
      return false;
    }
  }
}
