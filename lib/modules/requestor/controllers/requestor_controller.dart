import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/request_repository.dart';
import 'my_requests_controller.dart';

class RequestorController extends GetxController {
  final currentIndex = 0.obs;
  // Initialize repository (ensure it's available in bindings)
  final RequestRepository _repository = Get.find<RequestRepository>();

  final pendingCount = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 1) {
      if (Get.isRegistered<MyRequestsController>()) {
        Get.find<MyRequestsController>().fetchRequests();
      }
    } else if (index == 0) {
      fetchPendingCount();
    }
  }

  // Pending: Refactor this to use API if needed later. Keeping for now as User didn't ask to fix Recent Requests specifically, but only Pending Count.
  final recentRequests = <Map<String, dynamic>>[
    {
      'title': 'Team Lunch',
      'date': '12 Dec 2023',
      'amount': 45.00,
      'status': 'Pending',
      'icon': Icons.restaurant,
      'color': AppColors.warning.withOpacity(0.1),
      'iconColor': AppColors.warning,
    },
    {
      'title': 'Flight to Conference',
      'date': '10 Dec 2023',
      'amount': 289.99,
      'status': 'Approved',
      'icon': Icons.flight,
      'color': AppColors.primary.withOpacity(0.1),
      'iconColor': AppColors.primary,
    },
    {
      'title': 'Taxi from Airport',
      'date': '08 Dec 2023',
      'amount': 25.50,
      'status': 'Rejected',
      'icon': Icons.directions_car,
      'color': AppColors.error.withOpacity(0.1),
      'iconColor': AppColors.error,
    },
  ].obs;

  final userName = ''.obs;

  final showWelcome = true.obs;

  String get shortName {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;

    if (user == null) return 'Requestor';

    // Prioritize firstName
    if (user.firstName.isNotEmpty) {
      return user.firstName;
    }

    // Fallback to full name logic
    String name = user.name;
    if (name.isEmpty || name == 'Unknown') {
      name = user.email.isNotEmpty ? user.email : 'Requestor';
    }

    if (name.contains(' ')) {
      return name.split(' ').first;
    }
    return name;
  }

  @override
  void onInit() {
    super.onInit();
    // No need to manually set userName, we use the getter now directly from AuthService
    // But if we want to keep userName observable for other uses:
    final authService = Get.find<AuthService>();
    if (authService.currentUser.value != null) {
      userName.value = authService.currentUser.value!.name;
    } else {
      userName.value = 'Requestor';
    }

    // Auto-hide welcome message after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      showWelcome.value = false;
    });

    fetchPendingCount();
  }

  Future<void> fetchPendingCount() async {
    try {
      final requests = await _repository.getMyRequests(status: 'pending');
      pendingCount.value = requests.length;
    } catch (e) {
      print('Error fetching pending count: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
