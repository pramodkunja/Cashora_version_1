import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/admin_approvals_controller.dart'; // Reuse for navigation or separate
import '../controllers/admin_dashboard_controller.dart';

class AdminSuccessView extends StatelessWidget {
  const AdminSuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Checkmark Icon
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 64,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              AppText.approvedSuccessTitle,
              style: AppTextStyles.h1.copyWith(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppText.approvedSuccessDesc,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSlate,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),

            PrimaryButton(
              text: AppText.backToApprovals,
              onPressed: () {
                Get.offNamedUntil(AppRoutes.ADMIN_DASHBOARD, (route) => false);
                // Delay to ensure controller is ready or reuse existing if not disposed
                Future.delayed(const Duration(milliseconds: 100), () {
                  try {
                    final ctrl = Get.find<AdminDashboardController>();
                    ctrl.changeTab(1);
                  } catch (_) {}
                });
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
