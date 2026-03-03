import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../../../core/services/network_service.dart';
import '../views/widgets/admin_rejection_dialog.dart';
import '../../../../utils/widgets/app_loader.dart';

class AdminRequestDetailsController extends GetxController {
  late final AdminRepository _adminRepository;

  final request = {}.obs;
  final clarificationController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _adminRepository = AdminRepository(Get.find<NetworkService>());
    if (Get.arguments != null) {
      request.value = Get.arguments;
    }
  }

  @override
  void onClose() {
    clarificationController.dispose();
    super.onClose();
  }

  Future<void> approveRequest() async {
    try {
      isLoading.value = true;
      final id = request['id']; // Use numeric ID
      if (id == null) {
        Get.snackbar('Error', 'Invalid Request ID');
        return;
      }

      await _adminRepository.approveRequest(id);
      Get.offNamed(
        AppRoutes.ADMIN_SUCCESS,
      ); // Navigate to success and clear stack/history if needed or just push
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void rejectRequest() {
    Get.bottomSheet(
      AdminRejectionDialog(
        onConfirm: (reason) async {
          try {
            isLoading.value = true;
            Get.back(); // Close sheet first

            final id = request['id']; // Use numeric ID
            if (id == null) {
              Get.snackbar('Error', 'Invalid Request ID');
              return;
            }

            await _adminRepository.rejectRequest(id, reason);
            Get.offNamed(AppRoutes.ADMIN_REJECTION_SUCCESS);
          } catch (e) {
            Get.snackbar('Error', 'Failed to reject: $e');
          } finally {
            isLoading.value = false;
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void askClarification() {
    Get.toNamed(
      AppRoutes.ADMIN_CLARIFICATION,
    ); // Just navigation to input screen
  }

  // Called from the separate Clarification Input Screen
  Future<void> submitClarification() async {
    if (clarificationController.text.isNotEmpty) {
      try {
        isLoading.value = true;
        final expense_id = request['id'];
        if (expense_id == null) {
          Get.snackbar('Error', 'Invalid Request ID');
          return;
        }

        // id is likely int from API, but safe cast if needed, though dynamic handles it if repo expects dynamic/int
        // Repo expects int.
        await _adminRepository.askClarification(
          expense_id,
          clarificationController.text,
        );
        Get.offNamed(AppRoutes.ADMIN_CLARIFICATION_SUCCESS);
      } catch (e) {
        Get.snackbar('Error', 'Failed to send clarification: $e');
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar('Error', 'Please enter your question or comment');
    }
  }

  void viewAttachment(String url) {
    if (url.isEmpty) return;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 500, // Reasonable height or use constraints
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: AppSpinner());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                            const SizedBox(height: 10),
                            const Text("Unable to preview this file type."),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text("Open Externally"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
