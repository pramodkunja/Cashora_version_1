import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/admin/views/admin_set_limits_view.dart';
import '../modules/admin/controllers/admin_set_limits_controller.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/lock/views/lock_view.dart';
import '../core/services/storage_service.dart';
import '../modules/admin/views/admin_dashboard_view.dart';
import '../modules/admin/views/admin_main_view.dart';
import '../modules/admin/views/admin_approvals_view.dart';
import '../modules/admin/views/admin_request_details_view.dart';
import '../modules/admin/views/admin_success_view.dart';
import '../modules/admin/controllers/admin_dashboard_controller.dart';
import '../modules/admin/controllers/admin_approvals_controller.dart';
import '../modules/admin/controllers/admin_request_details_controller.dart';
import '../modules/admin/controllers/admin_request_details_controller.dart';
import '../modules/admin/views/admin_rejection_success_view.dart';
import '../modules/admin/views/admin_clarification_view.dart';
import '../modules/admin/views/admin_clarification_success_view.dart';
import '../modules/admin/views/admin_history_view.dart';
import '../modules/admin/views/admin_clarification_status_view.dart';
import '../modules/admin/controllers/admin_clarification_status_controller.dart';
import '../modules/admin/controllers/admin_history_controller.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/settings_view.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../modules/profile/controllers/settings_controller.dart';
import '../modules/settings/views/notifications_view.dart';
import '../modules/settings/views/appearance_view.dart';
import '../modules/settings/views/change_password_view.dart';
import '../modules/admin/views/user_management/admin_user_list_view.dart';
import '../modules/admin/views/user_management/admin_add_user_view.dart';
import '../modules/admin/views/user_management/admin_edit_user_view.dart';
import '../modules/admin/views/user_management/admin_deactivate_user_view.dart';
import '../modules/admin/views/user_management/admin_user_success_view.dart';
import '../modules/admin/controllers/admin_user_controller.dart';
import 'app_routes.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/organization_setup/bindings/organization_setup_binding.dart';
import '../modules/organization_setup/views/organization_setup_view.dart';
import '../modules/organization_setup/views/organization_success_view.dart';
import '../modules/notifications/views/requestor_notifications_view.dart';
import '../modules/notifications/views/admin_notifications_view.dart';
import '../modules/notifications/views/accountant_notifications_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/otp_verification/bindings/otp_verification_binding.dart';
import '../modules/otp_verification/views/otp_verification_view.dart';
import '../modules/reset_password/bindings/reset_password_binding.dart';
import '../modules/reset_password/views/reset_password_view.dart';
import '../modules/reset_password/views/reset_password_success_view.dart';
import '../modules/requestor/bindings/requestor_binding.dart';
import '../modules/requestor/views/requestor_dashboard_view.dart';
import '../modules/requestor/views/requestor_main_view.dart';
import '../modules/requestor/bindings/create_request_binding.dart';
import '../modules/requestor/views/create_request/select_request_type_view.dart';
import '../modules/requestor/views/create_request/request_details_view.dart';
import '../modules/requestor/views/create_request/review_request_view.dart';
import '../modules/requestor/views/create_request/request_success_view.dart';
import '../modules/requestor/views/monthly_spent_view.dart';
import '../modules/requestor/views/my_requests_view.dart';
import '../modules/requestor/views/request_details_read_view.dart';
import '../modules/requestor/controllers/my_requests_controller.dart';
import '../modules/requestor/views/provide_clarification_view.dart';
import '../modules/requestor/controllers/provide_clarification_controller.dart';
import '../core/services/auth_service.dart';
import '../modules/accountant/views/accountant_dashboard_view.dart';
import '../modules/accountant/controllers/accountant_dashboard_controller.dart';
import '../modules/accountant/views/accountant_payments_view.dart';
import '../modules/accountant/controllers/accountant_payments_controller.dart';
import '../modules/accountant/views/accountant_profile_view.dart';
import '../modules/accountant/controllers/accountant_profile_controller.dart';
import '../modules/accountant/views/payment_flow/request_details_view.dart';
import '../modules/accountant/views/payment_flow/bill_details_view.dart';
import '../modules/accountant/views/payment_flow/verify_payment_view.dart';
import '../modules/accountant/views/payment_flow/confirm_payment_view.dart';
import '../modules/accountant/views/payment_flow/payment_success_view.dart';
import '../modules/accountant/controllers/payment_flow_controller.dart';
import '../modules/accountant/views/payment_flow/payment_failed_view.dart';
import '../modules/accountant/views/payment_flow/completed_request_details_view.dart';
import '../modules/accountant/views/analytics/spend_analytics_view.dart';
import '../modules/accountant/views/analytics/financial_reports_view.dart';
import '../core/constants/user_roles.dart'; // Added Import
import '../modules/accountant/controllers/accountant_analytics_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.find<AuthService>().isLoggedIn) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    return null;
  }
}

class RouteGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // 1. Check Login
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    // 2. Check Session Verification (Strict Startup)
    if (!authService.isSessionVerified.value) {
      return const RouteSettings(name: AppRoutes.LOCK);
    }

    final user = authService.currentUser.value;
    final role = user?.role.toLowerCase() ?? '';

    // 3. Firewall: Block unauthorized access based on URL signatures
    if (route != null) {
      // Block Admin routes for non-admins
      if (route.startsWith('/admin') &&
          role != UserRoles.ADMIN &&
          role != UserRoles.SUPER_ADMIN) {
        Get.snackbar(
          'Access Denied',
          'You are not authorized to access this area.',
        );
        return _getDashboardRoute(role);
      }

      // Block Accountant routes for non-accountants
      if (route.startsWith('/accountant') && role != UserRoles.ACCOUNTANT) {
        Get.snackbar(
          'Access Denied',
          'You are not authorized to access this area.',
        );
        return _getDashboardRoute(role);
      }
    }

    // 4. Force Redirect from Root
    // if (route == AppRoutes.INITIAL || route == '/') {
    //    return _getDashboardRoute(role);
    // }

    return null; // Allow access
  }

  RouteSettings _getDashboardRoute(String role) {
    if (role == UserRoles.ADMIN || role == UserRoles.SUPER_ADMIN)
      return const RouteSettings(name: AppRoutes.ADMIN_DASHBOARD);
    if (role == UserRoles.ACCOUNTANT)
      return const RouteSettings(name: AppRoutes.ACCOUNTANT_DASHBOARD);
    return const RouteSettings(name: AppRoutes.REQUESTOR);
  }
}

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),

    GetPage(name: AppRoutes.LOCK, page: () => const LockView()),

    GetPage(
      name: AppRoutes.INITIAL, // '/'
      page: () => const SizedBox(),
      middlewares: [RouteGuard()],
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.ORGANIZATION_SETUP,
      page: () => const OrganizationSetupView(),
      binding: OrganizationSetupBinding(),
    ),
    GetPage(
      name: AppRoutes.ORGANIZATION_SUCCESS,
      page: () => const OrganizationSuccessView(),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.OTP_VERIFICATION,
      page: () => const OtpVerificationView(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.RESET_PASSWORD_SUCCESS,
      page: () => const ResetPasswordSuccessView(),
    ),
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
    ),
    GetPage(
      name: AppRoutes.MONTHLY_SPENT,
      page: () => const MonthlySpentView(),
    ),
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
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.put(SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.SETTINGS_NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.put(SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.SETTINGS_APPEARANCE,
      page: () => const AppearanceView(),
      binding: BindingsBuilder(() {
        Get.put(SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.SETTINGS_CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.put(SettingsController());
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
      name: AppRoutes.ACCOUNTANT_DASHBOARD,
      page: () => const AccountantDashboardView(),
      binding: BindingsBuilder(() {
        Get.put(AccountantDashboardController());
        Get.lazyPut(() => AccountantPaymentsController());
        Get.lazyPut(() => AccountantAnalyticsController());
        Get.lazyPut(() => AccountantProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_PAYMENTS,
      page: () => const AccountantPaymentsView(),
      binding: BindingsBuilder(() {
        Get.put(AccountantPaymentsController());
      }),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_PROFILE,
      page: () => const AccountantProfileView(),
      binding: BindingsBuilder(() {
        Get.put(AccountantProfileController());
      }),
    ),
    // Payment Flow Pages
    GetPage(
      name: AppRoutes.ACCOUNTANT_PAYMENT_REQUEST_DETAILS,
      page: () => const PaymentRequestDetailsView(),
      binding: BindingsBuilder(() {
        Get.put(PaymentFlowController());
      }),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_PAYMENT_BILL_DETAILS,
      page: () => const BillDetailsView(),
      binding: BindingsBuilder(() {
        // Reuse existing controller from PaymentRequestDetailsView
        if (!Get.isRegistered<PaymentFlowController>()) {
          Get.put(PaymentFlowController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_PAYMENT_VERIFY,
      page: () => const VerifyPaymentView(),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_PAYMENT_CONFIRM,
      page: () => const ConfirmPaymentView(),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_PAYMENT_SUCCESS,
      page: () => const PaymentSuccessView(),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_PAYMENT_FAILED,
      page: () => const PaymentFailedView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PaymentFlowController>()) {
          Get.put(PaymentFlowController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_PAYMENT_COMPLETED_DETAILS,
      page: () => const CompletedRequestDetailsView(),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_ANALYTICS,
      page: () => const SpendAnalyticsView(),
      binding: BindingsBuilder(() {
        Get.put(AccountantAnalyticsController());
      }),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_FINANCIAL_REPORTS,
      page: () => const FinancialReportsView(),
      binding: BindingsBuilder(() {
        Get.put(AccountantAnalyticsController());
      }),
    ),
    GetPage(
      name: AppRoutes.REQUESTOR_NOTIFICATIONS,
      page: () => const RequestorNotificationView(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_NOTIFICATIONS,
      page: () => const AdminNotificationView(),
    ),
    GetPage(
      name: AppRoutes.ACCOUNTANT_NOTIFICATIONS,
      page: () => const AccountantNotificationView(),
    ),
  ];
}
