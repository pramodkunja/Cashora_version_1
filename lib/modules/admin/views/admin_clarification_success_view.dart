import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../routes/app_routes.dart';

class AdminClarificationSuccessView extends StatelessWidget {
  const AdminClarificationSuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Get.offAllNamed(AppRoutes.ADMIN_APPROVALS),
        ),
        centerTitle: true,
        title: Text(AppText.success, style: AppTextStyles.h3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE), // Light blue bg
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.primaryBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppText.sentBackSuccessfully,
              style: AppTextStyles.h1.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppText.sentBackDesc,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSlate,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            PrimaryButton(
              text: AppText.backToApprovalsList,
              onPressed: () => Get.offAllNamed(AppRoutes.ADMIN_APPROVALS),
              width: double.infinity,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
