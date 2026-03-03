import 'package:get/get.dart';
import '../controllers/organization_setup_controller.dart';
import '../../../data/repositories/organization_repository.dart';
import '../../../core/services/network_service.dart';

class OrganizationSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrganizationRepository(Get.find<NetworkService>()));
    Get.lazyPut<OrganizationSetupController>(
      () => OrganizationSetupController(Get.find<OrganizationRepository>()),
    );
  }
}
