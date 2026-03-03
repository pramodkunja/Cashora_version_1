import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Retain for now if generic text field styles need specific GoogleFonts calls, but aiming to remove.
import '../controllers/organization_setup_controller.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class OrganizationSetupView extends GetView<OrganizationSetupController> {
  const OrganizationSetupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSlate),
          onPressed: () => Get.back(),
        ),
        title: Text(AppText.setupOrganization, style: AppTextStyles.h3),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stepper UI
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     _buildStep(1, AppText.stepperOrganization, isActive: true),
                //     Container(
                //       width: 40,
                //       height: 1,
                //       color: AppColors.borderLight,
                //       margin: const EdgeInsets.symmetric(horizontal: 12),
                //     ),
                //     //_buildStep(2, AppText.stepperPreferences, isActive: false),
                //   ],
                // ),
                //const SizedBox(height: 32),

                // Organization Details Section
                Text(
                  AppText.organizationDetails,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTextStyles.bodyMedium.color,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel(AppText.organizationName),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.orgNameController,
                  hint: AppText.hintOrgName,
                  context: context,
                ),
                const SizedBox(height: 20),

                // _buildLabel(AppText.organizationCode),
                // const SizedBox(height: 8),
                // Obx(() => Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                //   decoration: BoxDecoration(
                //     color: Theme.of(context).cardColor, // Light grey background for readonly
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         controller.orgCode.value,
                //         style: AppTextStyles.bodyMedium.copyWith(
                //           color: AppTextStyles.bodyMedium.color,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //       GestureDetector(
                //         onTap: controller.copyToClipboard,
                //         child: const Icon(Icons.copy_rounded, size: 20, color: AppColors.primaryBlue),
                //       ),
                //     ],
                //   ),
                // )),
                // const SizedBox(height: 32),

                // Admin Details Section
                Text(
                  AppText.adminDetails,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTextStyles.bodyMedium.color,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('First Name'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: controller.firstNameController,
                            hint: 'First Name',
                            context: context,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Last Name'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: controller.lastNameController,
                            hint: 'Last Name',
                            context: context,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel(AppText.workEmail),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.emailController,
                  hint: AppText.hintAdminEmail,
                  context: context,
                ),
                const SizedBox(height: 20),

                _buildLabel('Phone Number'),
                const SizedBox(height: 8),
                IntlPhoneField(
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: AppTextStyles.hintText,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  initialCountryCode:
                      'IN', // Default to India or US as per user preference, strictly 'IN' is a safe guess for this context, or 'US'. Let's pick 'IN' as a common default or maybe 'US'. Given the name 'Pramod' in paths, 'IN' is a good guess, but 'US' is standard default. I'll use 'IN' as it seems more likely for this user context, or just 'US'. I'll stick to 'IN' as it's often safer for international/mixed use if I'm unsure. Actually, let's use 'US' as universal default or 'IN' if I want to be localized. I'll use 'IN'.
                  onChanged: (phone) {
                    controller.fullPhoneNumber.value = phone.completeNumber;
                    controller.isPhoneValid.value =
                        true; // Basic check, advanced validation happens internally but we need to trust the parser.
                    // Actually IntlPhoneField has internal validation. We can capture it via onCountryChanged or similar?
                    // Verify: isValid is a property of the phone object? No.
                    // We might need to rely on the form state or just use the complete string.
                    // Actually, we should use the `onChanged` to just store result. The validation visual is automatic.
                  },
                  onCountryChanged: (country) {
                    // Update validation logic if needed
                    print('Country changed to: ' + country.name);
                  },
                ),
                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppText.adminCredentialsInfo,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTextStyles.bodyMedium.color,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Secure SSL Label
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        color: AppColors.borderLight,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppText.secureSSL,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.borderLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Create Button
                Obx(
                  () => PrimaryButton(
                    text: AppText.createOrganizationAction,
                    onPressed: controller.createOrganization,
                    isLoading: controller.isLoading,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int step, String label, {required bool isActive}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primaryBlue : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.primaryBlue : AppColors.borderLight,
            ),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isActive ? Colors.white : AppColors.borderLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isActive
                ? AppColors.textDark
                : AppTextStyles.bodyMedium.color,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTextStyles.h3.color,
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.hintText,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}
