import 'package:get/get.dart';

import '../../core/services/network_service.dart';
import '../../data/repositories/request_repository.dart';
import '../../modules/notifications/views/requestor_notifications_view.dart';
import '../../modules/requestor/bindings/create_request_binding.dart';
import '../../modules/requestor/bindings/requestor_binding.dart';
import '../../modules/requestor/controllers/my_requests_controller.dart';
import '../../modules/requestor/controllers/provide_clarification_controller.dart';
import '../../modules/requestor/views/create_request/request_details_view.dart';
import '../../modules/requestor/views/create_request/request_success_view.dart';
import '../../modules/requestor/views/create_request/review_request_view.dart';
import '../../modules/requestor/views/create_request/select_request_type_view.dart';
import '../../modules/requestor/views/my_requests_view.dart';
import '../../modules/requestor/views/provide_clarification_view.dart';
import '../../modules/requestor/views/request_details_read_view.dart';
import '../../modules/requestor/views/requestor_main_view.dart';
import '../app_routes.dart';

/// Requestor-side routes — requestor home shell, the multi-step
/// create-request flow, my-requests list, read-only request details,
/// clarification respond screen, and requestor notifications.
final List<GetPage> requestorRoutes = [
  GetPage(
    name: AppRoutes.REQUESTOR,
    page: () => const RequestorMainView(),
    binding: RequestorBinding(),
  ),
  GetPage(
    name: AppRoutes.CREATE_REQUEST_TYPE,
    page: () => const SelectRequestTypeView(),
    binding: CreateRequestBinding(),
  ),
  GetPage(
    name: AppRoutes.CREATE_REQUEST_DETAILS,
    page: () => const RequestDetailsView(),
    binding: CreateRequestBinding(),
  ),
  GetPage(
    name: AppRoutes.CREATE_REQUEST_REVIEW,
    page: () => const ReviewRequestView(),
    binding: CreateRequestBinding(),
  ),
  GetPage(
    name: AppRoutes.CREATE_REQUEST_SUCCESS,
    page: () => const RequestSuccessView(),
    binding: CreateRequestBinding(),
  ),
  GetPage(
    name: AppRoutes.MY_REQUESTS,
    page: () => const MyRequestsView(),
    binding: BindingsBuilder(() {
      Get.put(MyRequestsController());
    }),
  ),
  GetPage(
    name: AppRoutes.REQUESTOR_CLARIFICATION,
    page: () => const ProvideClarificationView(),
    binding: BindingsBuilder(() {
      Get.put(ProvideClarificationController());
    }),
  ),
  GetPage(
    name: AppRoutes.REQUEST_DETAILS_READ,
    page: () => const RequestDetailsReadView(),
    binding: BindingsBuilder(() {
      if (!Get.isRegistered<RequestRepository>()) {
        Get.put<RequestRepository>(
          RequestRepository(Get.find<NetworkService>()),
        );
      }
    }),
  ),
  GetPage(
    name: AppRoutes.REQUESTOR_NOTIFICATIONS,
    page: () => const RequestorNotificationView(),
  ),
];
