import 'package:get/get.dart';
import 'package:dio/dio.dart';

class BaseController extends GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  void showLoading() {
    _isLoading.value = true;
  }

  void hideLoading() {
    _isLoading.value = false;
  }

  void handleError(dynamic error) {
    hideLoading();
    String message = 'An unexpected error occurred';
    if (error is DioException) {
      if (error.response?.data != null) {
        if (error.response!.data is Map) {
          message =
              error.response!.data['detail'] ??
              error.response!.data['message'] ??
              error.message ??
              'Server error';
        } else {
          message = error.response!.data.toString();
        }
      } else {
        message = error.message ?? 'Network error';
      }
    } else {
      message = error.toString();
    }
    _errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  Future<void> performAsyncOperation(Future<void> Function() operation) async {
    try {
      showLoading();
      await operation();
    } catch (e) {
      handleError(e);
    } finally {
      hideLoading();
    }
  }
}
