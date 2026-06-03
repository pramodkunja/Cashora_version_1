import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import 'package:cash/utils/widgets/app_gradient_header.dart';
import '../../../../utils/app_text.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          AppGradientHeader(title: 'Edit Profile'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar
                  Center(
                    child: Obx(
                      () => Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.purpleSurface, width: 3.w),
                        ),
                        child: CircleAvatar(
                          radius: 44.r,
                          backgroundColor: AppColors.purpleSurface,
                          child: Text(
                            _initials(controller.rxName.value),
                            style: GoogleFonts.inter(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  _buildCard(
                    icon: Icons.person_rounded,
                    title: 'Personal Info',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                label: 'First Name',
                                controller: controller.firstNameController,
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _field(
                                label: 'Last Name',
                                controller: controller.lastNameController,
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        _field(
                          label: AppText.phone,
                          controller: controller.phoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  _buildCard(
                    icon: Icons.lock_person_rounded,
                    title: 'Read-only',
                    child: Column(
                      children: [
                        _field(
                          label: AppText.emailAddress,
                          controller: controller.emailController,
                          icon: Icons.email_outlined,
                          readOnly: true,
                        ),
                        SizedBox(height: 14.h),
                        _field(
                          label: AppText.role,
                          controller: controller.roleController,
                          icon: Icons.badge_outlined,
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: controller.isSaving.value ? null : controller.saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: controller.isSaving.value
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _field({
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
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSlate,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: readOnly ? AppColors.textSlate : AppColors.textDark,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: readOnly ? AppColors.slate300 : AppColors.textSlate,
                size: 18.sp,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
