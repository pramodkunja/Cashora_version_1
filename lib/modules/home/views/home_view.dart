import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_text.dart';
import '../../../core/services/auth_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Obx(
          () => Text(
            'Welcome, ${authService.currentUser.value?.name ?? "User"}!',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
