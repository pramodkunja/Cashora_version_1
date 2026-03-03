import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 24.sp,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text('Edit Profile', style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Edit
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 4.w),
                ),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: AppColors.backgroundLight,
                  child: Icon(
                    Icons.person,
                    size: 50.sp,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Form Fields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'First Name',
                    controller: controller.firstNameController,
                    icon: Icons.person_outline,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'Last Name',
                    controller: controller.lastNameController,
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            _buildTextField(
              context,
              label: AppText.emailAddress,
              controller:
                  controller.emailController, // Should be read-only logically
              icon: Icons.email_outlined,
              readOnly: true,
            ),
            SizedBox(height: 20.h),

            _buildTextField(
              context,
              label: AppText.phone,
              controller: controller.phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20.h),

            _buildTextField(
              context,
              label: AppText.role,
              controller: controller.roleController, // Read-only
              icon: Icons.badge_outlined,
              readOnly: true,
            ),

            SizedBox(height: 40.h),

            Obx(
              () => PrimaryButton(
                text: 'Save Changes',
                onPressed: controller.saveProfile,
                isLoading: controller.isSaving.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTextStyles.bodyMedium.color,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge.copyWith(
            color: readOnly ? AppColors.textSlate : AppColors.textDark,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: readOnly ? AppColors.textSlate : AppColors.textLight,
              size: 24.sp,
            ),
            filled: true,
            fillColor: readOnly
                ? AppColors
                      .backgroundLight // or a specific read-only color
                : Theme.of(context).cardColor,
            contentPadding: EdgeInsets.symmetric(vertical: 16.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: readOnly
                    ? Theme.of(context).dividerColor
                    : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
