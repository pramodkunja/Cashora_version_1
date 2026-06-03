import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/cashora_design.dart';
import '../../profile/controllers/settings_controller.dart';

class AppearanceView extends GetView<SettingsController> {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: CashoraColors.bgB,
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                AppTopBar(title: 'Appearance', onBack: () => Get.back()),
                Expanded(
                  child: WhiteSheet(
                    bottomInset: bottomInset,
                    padding:
                        const EdgeInsets.fromLTRB(24, 14, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EntranceWrap(
                          duration: const Duration(milliseconds: 600),
                          child: const HeroBadge(
                            icon: Icons.palette_outlined,
                            diameter: 84,
                            iconSize: 38,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 700),
                          child: const HeroHeadline(
                            eyebrow: 'APP THEME',
                            headline: 'Choose your look',
                            subtitle:
                                'Pick the theme that feels best — change it anytime.',
                          ),
                        ),
                        SizedBox(height: 24.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 850),
                          child: Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                    color: CashoraColors.ink200),
                              ),
                              child: Column(
                                children: [
                                  _option(
                                    icon: Icons.light_mode_rounded,
                                    label: AppText.lightTheme,
                                    subtitle: 'Recommended',
                                    iconColor: const Color(0xFFF59E0B),
                                    iconBg: const Color(0xFFFFFBEB),
                                    selected: controller
                                            .rxPendingThemeMode.value ==
                                        0,
                                    onTap: () => controller.selectTheme(0),
                                    isFirst: true,
                                  ),
                                  Divider(
                                      height: 0,
                                      indent: 62.w,
                                      color: CashoraColors.ink200),
                                  _option(
                                    icon: Icons.dark_mode_rounded,
                                    label: AppText.darkTheme,
                                    subtitle: 'Easy on the eyes',
                                    iconColor: const Color(0xFF6366F1),
                                    iconBg: const Color(0xFFEEF2FF),
                                    selected: controller
                                            .rxPendingThemeMode.value ==
                                        1,
                                    onTap: () => controller.selectTheme(1),
                                  ),
                                  Divider(
                                      height: 0,
                                      indent: 62.w,
                                      color: CashoraColors.ink200),
                                  _option(
                                    icon: Icons.settings_suggest_rounded,
                                    label: AppText.systemDefault,
                                    subtitle: 'Follows device setting',
                                    iconColor: const Color(0xFF3B82F6),
                                    iconBg: const Color(0xFFEFF6FF),
                                    selected: controller
                                            .rxPendingThemeMode.value ==
                                        2,
                                    onTap: () => controller.selectTheme(2),
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 28.h),
                        EntranceWrap(
                          duration: const Duration(milliseconds: 1050),
                          child: GradientButton(
                            label: AppText.saveChanges,
                            onTap: controller.saveThemeChanges,
                            leadingIcon: Icons.check_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _option({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color iconColor,
    required Color iconBg,
    required bool selected,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? Radius.circular(18.r) : Radius.zero,
        bottom: isLast ? Radius.circular(18.r) : Radius.zero,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: selected
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.vertical(
                  top: isFirst ? Radius.circular(18.r) : Radius.zero,
                  bottom: isLast ? Radius.circular(18.r) : Radius.zero,
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: CashoraColors.ink900,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: CashoraColors.ink500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : CashoraColors.ink300,
                  width: 2.w,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
