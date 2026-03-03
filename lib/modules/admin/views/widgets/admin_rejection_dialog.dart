import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../utils/widgets/buttons/secondary_button.dart';

class AdminRejectionDialog extends StatelessWidget {
  final Function(String) onConfirm;

  const AdminRejectionDialog({Key? key, required this.onConfirm})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppText.reasonForRejection,
            style: AppTextStyles.h2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            AppText.rejectionReasonHint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSlate,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppText.reasonLabel,
            style: AppTextStyles.h3.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration.collapsed(
                hintText: AppText.reasonPlaceholder,
                hintStyle: TextStyle(color: AppColors.textSlate),
              ),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: AppText.confirmReject,
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                onConfirm(reasonController.text);
              }
            },
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            text: AppText.cancel,
            onPressed: () => Get.back(),
            width: double.infinity,
            backgroundColor: Theme.of(context).disabledColor.withOpacity(0.1),
            textColor: AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
