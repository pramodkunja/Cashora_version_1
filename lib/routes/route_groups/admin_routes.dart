import 'package:get/get.dart';

import '../../modules/admin/controllers/admin_approvals_controller.dart';
import '../../modules/admin/controllers/admin_clarification_status_controller.dart';
import '../../modules/admin/controllers/admin_dashboard_controller.dart';
import '../../modules/admin/controllers/admin_history_controller.dart';
import '../../modules/admin/controllers/admin_request_details_controller.dart';
import '../../modules/admin/controllers/admin_set_limits_controller.dart';
import '../../modules/admin/controllers/admin_user_controller.dart';
import '../../modules/admin/controllers/category_controller.dart';
import '../../modules/admin/controllers/department_controller.dart';
import '../../modules/admin/views/admin_approvals_view.dart';
import '../../modules/admin/views/admin_clarification_status_view.dart';
import '../../modules/admin/views/admin_clarification_success_view.dart';
import '../../modules/admin/views/admin_clarification_view.dart';
import '../../modules/admin/views/admin_history_view.dart';
import '../../modules/admin/views/admin_main_view.dart';
import '../../modules/admin/views/admin_rejection_success_view.dart';
import '../../modules/admin/views/admin_request_details_view.dart';
import '../../modules/admin/views/admin_set_limits_view.dart';
import '../../modules/admin/views/admin_success_view.dart';
import '../../modules/admin/views/category_list_view.dart';
import '../../modules/admin/views/department_list_view.dart';
import '../../modules/admin/views/user_management/admin_add_user_view.dart';
import '../../modules/admin/views/user_management/admin_deactivate_user_view.dart';
import '../../modules/admin/views/user_management/admin_edit_user_view.dart';
import '../../modules/admin/views/user_management/admin_user_list_view.dart';
import '../../modules/admin/views/user_management/admin_user_success_view.dart';
import '../../modules/notifications/views/admin_notifications_view.dart';
import '../../modules/profile/controllers/profile_controller.dart';
import '../app_routes.dart';

/// Admin-side routes — dashboard, approvals + request details flow,
/// clarification flow, history, set-limits, departments, categories,
/// user-management CRUD, and admin notifications.
final List<GetPage> adminRoutes = [
  GetPage(
    name: AppRoutes.ADMIN_DASHBOARD,
    page: () => const AdminMainView(),
    binding: BindingsBuilder(() {
      Get.put(AdminDashboardController());
      Get.put(AdminApprovalsController());
      Get.put(AdminHistoryController());
      Get.put(ProfileController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_APPROVALS,
    page: () => const AdminApprovalsView(),
    binding: BindingsBuilder(() {
      Get.put(AdminApprovalsController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_REQUEST_DETAILS,
    page: () => const AdminRequestDetailsView(),
    binding: BindingsBuilder(() {
      Get.put(AdminRequestDetailsController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_SUCCESS,
    page: () => const AdminSuccessView(),
  ),
  GetPage(
    name: AppRoutes.ADMIN_REJECTION_SUCCESS,
    page: () => const AdminRejectionSuccessView(),
  ),
  GetPage(
    name: AppRoutes.ADMIN_CLARIFICATION,
    page: () => const AdminClarificationView(),
  ),
  GetPage(
    name: AppRoutes.ADMIN_CLARIFICATION_SUCCESS,
    page: () => const AdminClarificationSuccessView(),
  ),
  GetPage(
    name: AppRoutes.ADMIN_SET_LIMITS,
    page: () => const AdminSetLimitsView(),
    binding: BindingsBuilder(() {
      Get.put(AdminSetLimitsController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_DEPARTMENTS,
    page: () => const DepartmentListView(),
    binding: BindingsBuilder(() {
      Get.put(DepartmentController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_CATEGORIES,
    page: () => const CategoryListView(),
    binding: BindingsBuilder(() {
      Get.put(CategoryController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_HISTORY,
    page: () => const AdminHistoryView(),
    binding: BindingsBuilder(() {
      Get.put(AdminHistoryController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_CLARIFICATION_STATUS,
    page: () => const AdminClarificationStatusView(),
    binding: BindingsBuilder(() {
      Get.put(AdminClarificationStatusController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_USER_LIST,
    page: () => const AdminUserListView(),
    binding: BindingsBuilder(() {
      Get.put(AdminUserController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_ADD_USER,
    page: () => const AdminAddUserView(),
    binding: BindingsBuilder(() {
      Get.put(AdminUserController()); // Reuse controller
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_EDIT_USER,
    page: () => const AdminEditUserView(),
    binding: BindingsBuilder(() {
      Get.put(AdminUserController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_DEACTIVATE_USER,
    page: () => const AdminDeactivateUserView(),
    binding: BindingsBuilder(() {
      Get.put(AdminUserController());
    }),
  ),
  GetPage(
    name: AppRoutes.ADMIN_USER_SUCCESS,
    page: () => const AdminUserSuccessView(),
  ),
  GetPage(
    name: AppRoutes.ADMIN_NOTIFICATIONS,
    page: () => const AdminNotificationView(),
  ),
];
