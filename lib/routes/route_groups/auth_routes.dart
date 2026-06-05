import 'package:flutter/widgets.dart' show SizedBox;
import 'package:get/get.dart';

import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../../modules/forgot_password/views/forgot_password_view.dart';
import '../../modules/lock/views/lock_view.dart';
import '../../modules/organization_setup/bindings/organization_setup_binding.dart';
import '../../modules/organization_setup/views/organization_setup_view.dart';
import '../../modules/organization_setup/views/organization_success_view.dart';
import '../../modules/otp_verification/bindings/otp_verification_binding.dart';
import '../../modules/otp_verification/views/otp_verification_view.dart';
import '../../modules/reset_password/bindings/reset_password_binding.dart';
import '../../modules/reset_password/views/reset_password_view.dart';
import '../../modules/reset_password/views/reset_password_success_view.dart';
import '../../modules/splash/controllers/splash_controller.dart';
import '../../modules/splash/views/splash_view.dart';
import '../app_routes.dart';
import '../route_guards.dart';

/// Auth / onboarding routes — entry-points before the user has a
/// confirmed session: splash, lock, login, org setup, password
/// recovery flow.
final List<GetPage> authRoutes = [
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
];
