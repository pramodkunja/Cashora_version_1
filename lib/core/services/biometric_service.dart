import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService extends GetxService {
  final LocalAuthentication _auth = LocalAuthentication();
  final RxBool isSupported = false.obs;
  final RxBool canUseBiometrics = false.obs;

  Future<BiometricService> init() async {
    try {
      // NOTE: Using `canCheckBiometrics` without parentheses just in case the compiler
      // sees it as a getter/property due to library version quirks, though typically it's a method.
      // However, to be safe against "not a function" error, we can try checking type or just strict usage.
      // If the error persists, we might need to inspect the library source in node_modules equivalent.
      // For now, removing `isDeviceSupported` call if it's suspected to be missing in old versions,
      // but let's keep it and focus on the specific errors.

      bool isDeviceSupported = await _auth.isDeviceSupported();
      bool canCheck = await _auth.canCheckBiometrics;

      isSupported.value = isDeviceSupported;
      canUseBiometrics.value = canCheck;
    } on PlatformException catch (e) {
      print('Error initializing biometrics: $e');
      isSupported.value = false;
      canUseBiometrics.value = false;
    } catch (e) {
      // Catch generic errors like NoSuchMethodError
      print('Generic error init biometrics: $e');
      isSupported.value = false;
      canUseBiometrics.value = false;
    }
    return this;
  }

  Future<bool> authenticate() async {
    if (!isSupported.value || !canUseBiometrics.value) {
      print('Biometrics not supported or available');
      return false;
    }

    try {
      // API fallback: minimal parameters
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
      );
    } on PlatformException catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }
}
