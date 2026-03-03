import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/app_loader.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../controllers/admin_user_controller.dart';
import '../widgets/admin_app_bar.dart';

class AdminEditUserView extends GetView<AdminUserController> {
  const AdminEditUserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get user data outside of Obx since Maps are not reactive
    final user = controller.rxSelectedUser.value;

    // Safety check - if user data is empty, show loading
    if (user.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AdminAppBar(title: AppText.editUser),
        body: const Center(child: AppSpinner()),
      );
    }

    // Handle different field name variations like in the list view
    String name =
        user['full_name'] ??
        user['name'] ??
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    if (name.isEmpty) name = 'Unknown User';

    String email = user['email'] ?? 'No email';
    String phone = user['phone'] ?? user['phone_number'] ?? 'No phone';
    String role = user['role'] ?? 'Requestor';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AdminAppBar(
        title: AppText.editUser, // 'Edit User'
        actions: [
          Obx(() {
            final user = controller.rxSelectedUser.value;
            final isActive = user['isActive'] ?? user['is_active'] ?? true;
            return TextButton(
              onPressed: () =>
                  controller.confirmDeactivate(controller.rxSelectedUser.value),
              child: Text(
                isActive ? AppText.deactivateUser : AppText.activateUser,
                style: AppTextStyles.buttonText.copyWith(
                  color: isActive ? Colors.red : Colors.green,
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).cardColor,
        child: PrimaryButton(
          text: AppText.updateUser,
          onPressed: controller.updateUser,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Photo
              Center(
                child: CircleAvatar(
                  radius: 40, // Reduced from 50 to prevent overflow
                  backgroundColor:
                      Colors.orangeAccent, // Using same style as ProfileView
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 2).toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 20, // Reduced font size
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24), // Reduced spacing
              // Edit Form
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: AppText.firstName,
                      controller: controller.firstNameController,
                      hint: 'First Name',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      context,
                      label: AppText.lastName,
                      controller: controller.lastNameController,
                      hint: 'Last Name',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                context,
                label: AppText.emailAddress,
                controller: controller.emailController,
                hint: 'user@example.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                context,
                label: AppText.phone,
                controller: controller.phoneController,
                hint: '+91 9876543210',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // Role Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0, left: 4),
                    child: Text(
                      AppText.role,
                      style: AppTextStyles.h3.copyWith(fontSize: 14),
                    ),
                  ),
                  Obx(() {
                    const List<String> roles = [
                      'Admin',

                      'Requestor',
                      'Accountant',
                    ];

                    // Safety check: Ensure the selected role exists in the dropdown items
                    String? selectedValue = controller.selectedRole.value;

                    // Case-insensitive check to handle 'accountant' vs 'Accountant'
                    if (selectedValue.isNotEmpty) {
                      final matchingRole = roles.firstWhere(
                        (role) =>
                            role.toLowerCase() == selectedValue?.toLowerCase(),
                        orElse: () => '',
                      );
                      if (matchingRole.isNotEmpty) {
                        selectedValue = matchingRole;
                        // Update controller if case mismatch was found to keep valid state
                        if (selectedValue != controller.selectedRole.value) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.selectedRole.value = matchingRole;
                          });
                        }
                      } else {
                        // If role matches none, set to null to show hint and prevent crash
                        selectedValue = null;
                      }
                    } else {
                      selectedValue = null;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedValue,
                          isExpanded: true,
                          hint: Text(
                            'Select Role',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSlate,
                            ),
                          ),
                          items: roles.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: AppTextStyles.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              controller.selectedRole.value = newValue;
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 20),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0, left: 4),
          child: Text(label, style: AppTextStyles.h3.copyWith(fontSize: 14)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSlate,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
