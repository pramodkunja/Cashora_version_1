import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/organization_setup_controller.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import 'widgets/org_setup_header.dart';
import 'widgets/org_setup_section_card.dart';
import 'widgets/org_setup_admin_form.dart';
import 'widgets/org_setup_footer.dart';

class OrganizationSetupView extends StatefulWidget {
  const OrganizationSetupView({super.key});

  @override
  State<OrganizationSetupView> createState() => _OrganizationSetupViewState();
}

class _OrganizationSetupViewState extends State<OrganizationSetupView> {

  OrganizationSetupController get controller =>
      Get.find<OrganizationSetupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          const OrgSetupHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Organization Details Card ─────────────────
                    OrgSetupSectionCard(
                      icon: Icons.business_rounded,
                      title: AppText.organizationDetails,
                      children: [
                        const OrgSetupFieldLabel(AppText.organizationName),
                        SizedBox(height: 8.h),
                        OrgSetupTextField(
                          controller: controller.orgNameController,
                          hint: AppText.hintOrgName,
                          icon: Icons.apartment_rounded,
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // ── Admin Details Card ────────────────────────
                    OrgSetupAdminForm(controller: controller),

                    SizedBox(height: 20.h),

                    // ── Info Banner ───────────────────────────────
                    const OrgSetupInfoBanner(),

                    SizedBox(height: 24.h),

                    // ── Secure SSL Indicator ──────────────────────
                    const OrgSetupSslIndicator(),

                    SizedBox(height: 16.h),

                    // ── Create Button ─────────────────────────────
                    OrgSetupCreateButton(controller: controller),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
