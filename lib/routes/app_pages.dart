import 'package:get/get.dart';

import 'app_routes.dart';
import 'route_groups/accountant_routes.dart';
import 'route_groups/admin_routes.dart';
import 'route_groups/auth_routes.dart';
import 'route_groups/requestor_routes.dart';
import 'route_groups/shared_routes.dart';

// Re-export the middleware classes from their new home so any older
// import that pulled them from this file still resolves.
export 'route_guards.dart' show AuthMiddleware, RouteGuard;

/// Central route registry used by `GetMaterialApp.getPages`.
///
/// The full list is composed by concatenating five per-role groups
/// defined in `route_groups/`. Each group file owns its own imports +
/// `GetPage` entries, which keeps `app_pages.dart` itself tiny and
/// makes role-specific routing changes touch only one file.
class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.SPLASH;

  static final List<GetPage> routes = [
    ...authRoutes,
    ...requestorRoutes,
    ...adminRoutes,
    ...accountantRoutes,
    ...sharedRoutes,
  ];
}
