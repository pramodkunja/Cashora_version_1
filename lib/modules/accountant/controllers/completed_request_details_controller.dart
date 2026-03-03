import 'package:get/get.dart';

class CompletedRequestDetailsController extends GetxController {
  final isLoading = false.obs;
  final paymentDetails = <String, dynamic>{}.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      // Use data passed directly via Get.arguments (no API call needed)
      paymentDetails.value = Map<String, dynamic>.from(args);
    } else {
      errorMessage.value = 'No payment details provided';
    }
  }
}
