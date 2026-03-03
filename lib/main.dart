import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'core/services/storage_service.dart';
import 'core/services/network_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/biometric_service.dart';
import 'core/managers/app_lifecycle_manager.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/user_repository.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'utils/app_theme.dart';
import 'modules/auth/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();

  // Read theme
  final storage = Get.find<StorageService>();
  String? themeIndex = await storage.read('theme_mode');
  ThemeMode initialTheme = ThemeMode.system;
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

Future<void> initServices() async {
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => NetworkService().init());
  Get.lazyPut(() => AuthRepository(Get.find<NetworkService>()));
  Get.lazyPut(
    () => PaymentRepository(Get.find<NetworkService>()),
  ); // Added Payment Repo
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
