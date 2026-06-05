import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/constants/user_roles.dart';
import '../core/services/auth_service.dart';
import 'app_routes.dart';

/// Soft auth gate — redirects unauthenticated users to login but does
/// not enforce session verification or role isolation. Use [RouteGuard]
/// for protected screens.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.find<AuthService>().isLoggedIn) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    return null;
  }
}

/// Strict guard applied to every role-aware route — verifies login,
/// session, and that the URL's role-prefix matches the current user's
/// role. Cross-role navigation lands on the user's own dashboard with
/// an "Access Denied" snackbar.
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

    return null; // Allow access
  }

  RouteSettings _getDashboardRoute(String role) {
    if (role == UserRoles.ADMIN || role == UserRoles.SUPER_ADMIN) {
      return const RouteSettings(name: AppRoutes.ADMIN_DASHBOARD);
    }
    if (role == UserRoles.ACCOUNTANT) {
      return const RouteSettings(name: AppRoutes.ACCOUNTANT_DASHBOARD);
    }
    return const RouteSettings(name: AppRoutes.REQUESTOR);
  }
}
