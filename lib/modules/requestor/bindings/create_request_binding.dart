import 'package:get/get.dart';
import '../controllers/create_request_controller.dart';

class CreateRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateRequestController>(() => CreateRequestController());
  }
}
