import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/services/storage_service.dart';
import 'core/services/network_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/biometric_service.dart';
import 'core/services/fcm_service.dart';
import 'core/managers/app_lifecycle_manager.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/department_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'routes/app_pages.dart';
import 'utils/app_theme.dart';
import 'modules/auth/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Crashlytics has no web implementation — skip on web to avoid a startup
  // assertion. Android/iOS still report normally.
  if (!kIsWeb) {
    await _initCrashlytics();
  }
  await initServices();

  // Read theme
  final storage = Get.find<StorageService>();
  // Default to light theme. Only override if user explicitly saved a preference.
  ThemeMode initialTheme = ThemeMode.light;
  String? themeIndex = await storage.read('theme_mode');
  if (themeIndex != null) {
    switch (int.parse(themeIndex)) {
      case 0:
        initialTheme = ThemeMode.light;
        break;
      case 1:
        initialTheme = ThemeMode.dark;
        break;
      case 2:
        initialTheme = ThemeMode.system;
        break;
    }
  }

  runApp(MyApp(initialTheme: initialTheme));
}

/// Hook Flutter framework + async/platform errors into Firebase Crashlytics.
/// Collection is **disabled in debug** so dev stack traces don't pollute the
/// production dashboard. Release/profile builds report normally.
Future<void> _initCrashlytics() async {
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!AppConfig.kIsDebug);

  // Errors thrown inside the Flutter widget/render layer.
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
    crashlytics.recordFlutterFatalError(details);
  };

  // Uncaught async / platform errors that bypass the Flutter framework.
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> initServices() async {
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => NetworkService().init());
  Get.lazyPut(() => AuthRepository(Get.find<NetworkService>()));
  Get.lazyPut(
    () => PaymentRepository(Get.find<NetworkService>()),
  ); // Added Payment Repo
  Get.lazyPut(
    () => DepartmentRepository(Get.find<NetworkService>()),
    fenix: true,
  );
  Get.lazyPut(
    () => CategoryRepository(Get.find<NetworkService>()),
    fenix: true,
  );

  // FCM: must be registered BEFORE AuthService — when AuthService.init()
  // finds a persisted login, it calls
  // `Get.isRegistered<FCMService>() ? FCMService.registerToken() : skip`.
  // If FCMService isn't in the DI container yet that guard skips and the
  // device's FCM token never gets posted to the backend → no pushes.
  Get.lazyPut(
    () => NotificationRepository(Get.find<NetworkService>()),
    fenix: true,
  );
  await Get.putAsync(
    () => FCMService(Get.find<NotificationRepository>()).init(),
  );

  await Get.putAsync(
    () => AuthService(
      Get.find<AuthRepository>(),
      Get.find<StorageService>(),
    ).init(),
  );
  Get.put(UserRepository()); // Moved after AuthService
  await Get.putAsync(() => BiometricService().init());
  Get.put(AppLifecycleManager());
  // Inject AuthController to ensure it's available globally or for token logic
  Get.lazyPut(() => AuthController(), fenix: true);
}

class MyApp extends StatelessWidget {
  final ThemeMode initialTheme;
  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Petty Cash',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: initialTheme,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
