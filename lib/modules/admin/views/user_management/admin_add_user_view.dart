import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../controllers/admin_user_controller.dart';
import '../widgets/admin_app_bar.dart';

class AdminAddUserView extends GetView<AdminUserController> {
  const AdminAddUserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AdminAppBar(title: AppText.addNewUserTitle),
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.all(24.w),
      //   child: PrimaryButton(
      //     text: AppText.createUser,
      //     onPressed: () {
      //       if (formKey.currentState!.validate()) {
      //         controller.addUser(); // Should accept form data
      //       }
      //     },
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColors.backgroundAlt,
                    child: Icon(
                      Icons.person,
                      size: 40.sp,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              _buildLabel('First Name'),
              TextFormField(
                controller: controller.firstNameController,
                decoration: _inputDecoration(context, 'Enter first name'),
              ),
              SizedBox(height: 16.h),

              _buildLabel('Last Name'),
              TextFormField(
                controller: controller.lastNameController,
                decoration: _inputDecoration(context, 'Enter last name'),
              ),
              SizedBox(height: 16.h),

              _buildLabel(AppText.emailAddress),
              TextFormField(
                controller: controller.emailController,
                decoration: _inputDecoration(
                  context,
                  'ex: sarah@company.com',
                  icon: Icons.email_outlined,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),

              _buildLabel(AppText.phone),
              TextFormField(
                controller: controller.phoneController,
                decoration: _inputDecoration(
                  context,
                  '+1 (555) 000-0000',
                  icon: Icons.phone_outlined,
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),

              _buildLabel(AppText.role),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Theme.of(context).cardColor,
                      value: controller.selectedRole.value.isEmpty
                          ? null
                          : controller.selectedRole.value,
                      hint: Text(
                        AppText.selectRole,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSlate,
                      ),
                      items: ['Requestor', 'Accountant'].map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (v) => controller.selectedRole.value = v ?? '',
                    ),
                  ),
                ),
              ),

              SizedBox(height: 48.h),
              PrimaryButton(
                text: AppText.createUser,
                onPressed: controller.createUser,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(text, style: AppTextStyles.h3.copyWith(fontSize: 14.sp)),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String hint, {
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
      suffixIcon: icon != null
          ? Icon(icon, color: AppColors.textSlate, size: 20.sp)
          : null,
    );
  }
}
