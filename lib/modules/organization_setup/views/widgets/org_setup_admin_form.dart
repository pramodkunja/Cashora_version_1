import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/organization_setup_controller.dart';
import '../../../../utils/app_text.dart';
import 'org_setup_section_card.dart';
import 'org_setup_phone_field.dart';

class OrgSetupAdminForm extends StatelessWidget {
  const OrgSetupAdminForm({super.key, required this.controller});

  final OrganizationSetupController controller;

  @override
  Widget build(BuildContext context) {
    return OrgSetupSectionCard(
      icon: Icons.admin_panel_settings_rounded,
      title: AppText.adminDetails,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OrgSetupFieldLabel('First Name'),
                  SizedBox(height: 8.h),
                  OrgSetupTextField(
                    controller: controller.firstNameController,
                    hint: 'First Name',
                    icon: Icons.person_rounded,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OrgSetupFieldLabel('Last Name'),
                  SizedBox(height: 8.h),
                  OrgSetupTextField(
                    controller: controller.lastNameController,
                    hint: 'Last Name',
                    icon: Icons.person_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        const OrgSetupFieldLabel(AppText.workEmail),
        SizedBox(height: 8.h),
        OrgSetupTextField(
          controller: controller.emailController,
          hint: AppText.hintAdminEmail,
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 18.h),
        const OrgSetupFieldLabel('Phone Number'),
        SizedBox(height: 8.h),
        OrgSetupPhoneField(controller: controller),
      ],
    );
  }
}
