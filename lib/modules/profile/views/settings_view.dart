import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);

  static const _helpSupportUrl = 'https://cashora.onrender.com/#contact';
  static const _privacyPolicyUrl =
      'https://cashora.onrender.com/policies/privacy-policy';
  static const _termsUrl =
      'https://cashora.onrender.com/policies/terms-and-conditions';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.snackbar(
        'Unable to open link',
        'Could not open $url',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionLabel('PREFERENCES'),
                  SizedBox(height: 10.h),
                  _card([
                    _tile(
                      icon: Icons.notifications_rounded,
                      title: AppText.notifications,
                      onTap: controller.navigateToNotifications,
                    ),
                    _tile(
                      icon: Icons.currency_rupee_rounded,
                      title: AppText.currency,
                      onTap: () {},
                    ),
                    _tile(
                      icon: Icons.brightness_6_rounded,
                      title: AppText.appearance,
                      onTap: controller.navigateToAppearance,
                      isLast: true,
                    ),
                  ]),
                  SizedBox(height: 20.h),

                  _sectionLabel('SECURITY'),
                  SizedBox(height: 10.h),
                  _card([
                    _toggleTile(
                      icon: Icons.fingerprint_rounded,
                      title: AppText.faceIdTouchId,
                      rxValue: controller.rxFaceIdEnabled,
                      onChanged: controller.toggleFaceId,
                    ),
                    _tile(
                      icon: Icons.lock_rounded,
                      title: AppText.changePassword,
                      onTap: controller.navigateToChangePassword,
                      isLast: true,
                    ),
                  ]),
                  SizedBox(height: 20.h),

                  _sectionLabel('HELP & LEGAL'),
                  SizedBox(height: 10.h),
                  _card([
                    _tile(
                      icon: Icons.help_outline_rounded,
                      title: AppText.helpSupport,
                      onTap: () => _openUrl(_helpSupportUrl),
                    ),
                    _tile(
                      icon: Icons.shield_outlined,
                      title: AppText.privacyPolicy,
                      onTap: () => _openUrl(_privacyPolicyUrl),
                    ),
                    _tile(
                      icon: Icons.description_outlined,
                      title: AppText.termsOfService,
                      onTap: () => _openUrl(_termsUrl),
                      isLast: true,
                    ),
                  ]),

                  SizedBox(height: 32.h),

                  // Logout
                  GestureDetector(
                    onTap: controller.logout,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: AppColors.errorRed, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            AppText.logOut,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.errorRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        22.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            AppText.settings,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: _slate500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: _purple, size: 18.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _slate900,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: _slate300, size: 22.sp),
              ],
            ),
          ),
          if (!isLast)
            Divider(
                height: 0, indent: 62.w, color: const Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required RxBool rxValue,
    required Function(bool) onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: _purple, size: 18.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _slate900,
                  ),
                ),
              ),
              Obx(
                () => Switch.adaptive(
                  value: rxValue.value,
                  onChanged: onChanged,
                  activeColor: _purple,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0, indent: 62.w, color: const Color(0xFFF1F5F9)),
      ],
    );
  }
}
