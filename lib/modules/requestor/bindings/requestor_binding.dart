import 'package:get/get.dart';

import '../controllers/requestor_controller.dart';
import '../controllers/my_requests_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../data/repositories/request_repository.dart';
import '../../../core/services/network_service.dart';

class RequestorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestRepository>(
      () => RequestRepository(Get.find<NetworkService>()),
    );
    Get.lazyPut<RequestorController>(() => RequestorController());
    Get.lazyPut<MyRequestsController>(() => MyRequestsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
