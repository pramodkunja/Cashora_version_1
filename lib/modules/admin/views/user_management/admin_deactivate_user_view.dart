import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../controllers/admin_user_controller.dart';
import '../widgets/admin_app_bar.dart';

class AdminDeactivateUserView extends GetView<AdminUserController> {
  const AdminDeactivateUserView({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AdminAppBar(title: AppText.deactivateUser),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          final user = controller.rxSelectedUser.value;
          final name =
              user['full_name'] ??
              user['name'] ??
              '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
          final role = user['role'] ?? 'Requestor';
          final isActive = user['isActive'] ?? user['is_active'] ?? true;

          // Logic variables for dynamic UI
          final isCurrentlyActive = isActive;
          final actionTitle = isCurrentlyActive
              ? AppText.deactivateAccount
              : AppText.activateAccount;
          final actionDesc = isCurrentlyActive
              ? AppText.deactivateDesc
              : AppText.activateDesc;
          final actionButtonText = isCurrentlyActive
              ? AppText.deactivateUser
              : AppText.activateUser;
          final themeColor = isCurrentlyActive
              ? const Color(0xFF88DCF6)
              : Colors.green;
          final icon = isCurrentlyActive ? Icons.person_off : Icons.person_add;
          final iconBgColor = isCurrentlyActive
              ? (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0C4A6E)
                    : const Color(0xFFE0F2FE))
              : (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF064E3B)
                    : const Color(0xFFDCFCE7));
          final iconFgColor = isCurrentlyActive
              ? Colors.lightBlue
              : Colors.green;

          return Column(
            children: [
              const SizedBox(height: 20),
              // Big Icon
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Icon(icon, size: 60, color: iconFgColor),
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 30,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                actionTitle,
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                actionDesc,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSlate,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // User Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isCurrentlyActive
                          ? Colors.orangeAccent
                          : Colors.grey,
                      child: Text(
                        name.isNotEmpty
                            ? name.substring(0, 2).toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isNotEmpty ? name : 'Unknown User',
                            style: AppTextStyles.h3,
                          ),
                          Text(
                            role,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCurrentlyActive
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCurrentlyActive ? Icons.lock : Icons.check_circle,
                        color: isCurrentlyActive ? Colors.red : Colors.green,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'User ID: #${user['id'] ?? 'N/A'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        color: AppColors.textSlate,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: controller.rxIsTermsAccepted.value,
                    onChanged: (v) =>
                        controller.rxIsTermsAccepted.value = v ?? false,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.rxIsTermsAccepted.toggle(),
                      child: Text(
                        AppText.understandAction,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.rxIsTermsAccepted.value
                      ? controller.toggleUserStatus
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    // Light blue from image
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    actionButtonText,
                    style: AppTextStyles.buttonText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  AppText.cancel,
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.textSlate,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
