import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminRejectionSuccessView extends StatelessWidget {
  const AdminRejectionSuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () {
            Get.offNamedUntil(AppRoutes.ADMIN_DASHBOARD, (route) => false);
            Future.delayed(const Duration(milliseconds: 100), () {
              try {
                Get.find<AdminDashboardController>().changeTab(1);
              } catch (_) {}
            });
          },
        ),
        centerTitle: true,
        title: Text(AppText.confirmation, style: AppTextStyles.h3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF7F1D1D).withOpacity(0.5)
                    : const Color(0xFFFEE2E2), // Darker red in dark mode
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.thumb_down_alt_rounded,
                color: Color(0xFFEF4444), // Red
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppText.requestRejected,
              style: AppTextStyles.h1.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppText.requestRejectedDesc,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSlate,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            PrimaryButton(
              text: AppText.backToApprovalsList,
              onPressed: () {
                Get.offNamedUntil(AppRoutes.ADMIN_DASHBOARD, (route) => false);
                Future.delayed(const Duration(milliseconds: 100), () {
                  try {
                    Get.find<AdminDashboardController>().changeTab(1);
                  } catch (_) {}
                });
              },
              width: double.infinity,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
