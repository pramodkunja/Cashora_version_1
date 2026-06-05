import 'package:get/get.dart';

import '../../modules/accountant/controllers/accountant_analytics_controller.dart';
import '../../modules/accountant/controllers/accountant_dashboard_controller.dart';
import '../../modules/accountant/controllers/accountant_payments_controller.dart';
import '../../modules/accountant/controllers/accountant_profile_controller.dart';
import '../../modules/accountant/controllers/manage_balances_controller.dart';
import '../../modules/accountant/controllers/payment_flow_controller.dart';
import '../../modules/accountant/views/accountant_dashboard_view.dart';
import '../../modules/accountant/views/accountant_payments_view.dart';
import '../../modules/accountant/views/accountant_profile_view.dart';
import '../../modules/accountant/views/analytics/financial_reports_view.dart';
import '../../modules/accountant/views/analytics/spend_analytics_view.dart';
import '../../modules/accountant/views/manage_balances_view.dart';
import '../../modules/accountant/views/payment_flow/bill_details_view.dart';
import '../../modules/accountant/views/payment_flow/completed_request_details_view.dart';
import '../../modules/accountant/views/payment_flow/confirm_payment_view.dart';
import '../../modules/accountant/views/payment_flow/mark_as_paid_view.dart';
import '../../modules/accountant/views/payment_flow/payment_failed_view.dart';
import '../../modules/accountant/views/payment_flow/payment_success_view.dart';
import '../../modules/accountant/views/payment_flow/request_details_view.dart';
import '../../modules/accountant/views/payment_flow/verify_payment_view.dart';
import '../../modules/notifications/views/accountant_notifications_view.dart';
import '../app_routes.dart';

/// Accountant-side routes — dashboard shell, payments tabs, profile,
/// the full payment-processing flow (request details → bill → mark-as-
/// paid → verify → confirm → success/failed → completed details),
/// analytics, financial reports, manage balances, and accountant
/// notifications.
final List<GetPage> accountantRoutes = [
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
  // ── Payment flow ─────────────────────────────────────────────────────
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
    name: AppRoutes.ACCOUNTANT_PAYMENT_MARK_AS_PAID,
    page: () => const MarkAsPaidView(),
    binding: BindingsBuilder(() {
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
  // ── Analytics, reports, balances ────────────────────────────────────
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
    name: AppRoutes.ACCOUNTANT_MANAGE_BALANCES,
    page: () => const ManageBalancesView(),
    binding: BindingsBuilder(() {
      Get.put(ManageBalancesController());
    }),
  ),
  GetPage(
    name: AppRoutes.ACCOUNTANT_NOTIFICATIONS,
    page: () => const AccountantNotificationView(),
  ),
];
