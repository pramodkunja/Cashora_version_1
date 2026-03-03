import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../profile/controllers/profile_controller.dart';

import 'admin_approvals_controller.dart';

class AdminDashboardController extends GetxController {
  final count = 0.obs;

  // Tab index for bottom bar
  final currentIndex = 0.obs;

  String get shortName {
    final user = Get.find<AuthService>().currentUser.value;
    if (user == null) return 'Approver';

    // Use firstName if available, otherwise fall back to name parsing or email
    if (user.firstName.isNotEmpty) {
      return user.firstName;
    }

    String name = user.name;
    if (name.isEmpty || name == 'Unknown') {
      name = user.email.isNotEmpty ? user.email : 'Approver';
    }

    if (name.contains(' ')) {
      return name.split(' ').first;
    }
    return name;
  }

  final showWelcome = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Auto-hide welcome message after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      showWelcome.value = false;
    });
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 1) {
      if (Get.isRegistered<AdminApprovalsController>()) {
        final ctrl = Get.find<AdminApprovalsController>();
        ctrl.fetchAllRequests();
        ctrl.resetTab(); // Reset to first tab
      }
    } else if (index == 3) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile();
      }
    }
  }

  void navigateToApprovals() {
    changeTab(1);
  }
}
