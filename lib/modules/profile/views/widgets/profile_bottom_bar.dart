import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../admin/views/widgets/admin_bottom_bar.dart';
import '../../../requestor/views/widgets/requestor_bottom_bar.dart';

class ProfileBottomBar extends StatelessWidget {
  const ProfileBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userRole =
        Get.find<AuthService>().currentUser.value?.role.toLowerCase();

    if (userRole == 'admin' || userRole == 'super_admin') {
      return AdminBottomBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Get.offNamed(AppRoutes.ADMIN_DASHBOARD);
          if (index == 1) Get.offNamed(AppRoutes.ADMIN_APPROVALS);
          if (index == 2) Get.offNamed(AppRoutes.ADMIN_HISTORY);
        },
      );
    } else {
      return RequestorBottomBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Get.offNamed(AppRoutes.REQUESTOR);
          if (index == 1) Get.offNamed(AppRoutes.MY_REQUESTS);
        },
      );
    }
  }
}
