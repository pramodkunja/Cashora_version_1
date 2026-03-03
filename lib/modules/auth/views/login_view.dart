import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Dynamic background
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Animated Logo
                const Align(
                  alignment: Alignment.center,
                  child: AnimatedLoginLogo(),
                ),
                SizedBox(height: 32.h),

                // Welcome Text
                Text(
                  AppText.welcomeBack,
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  AppText.signInSubtitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSlate,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),

                // Email Input
                Text(
                  AppText.emailAddress,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTextStyles.bodyMedium.color,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => TextField(
                    controller: controller.emailController,
                    enabled: !controller.isLoading,
                    textInputAction: TextInputAction.next, // Next button
                    decoration: InputDecoration(
                      hintText: AppText.emailPlaceholder,
                      hintStyle: AppTextStyles.hintText,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.textLight,
                        size: 24.sp,
                      ),
                      filled: true,
                      fillColor: controller.isLoading
                          ? Theme.of(context).disabledColor.withOpacity(0.05)
                          : Theme.of(context).cardColor,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Password Input
                Text(
                  AppText.password,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTextStyles.bodyMedium.color,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => TextField(
                    controller: controller.passwordController,
                    obscureText: !controller.isPasswordVisible.value,
                    enabled: !controller.isLoading,
                    textInputAction: TextInputAction.done, // Done button
                    onSubmitted: (_) => controller.login(), // Auto-submit
                    decoration: InputDecoration(
                      hintText: AppText.passwordPlaceholder,
                      hintStyle: AppTextStyles.hintText,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.textLight,
                        size: 24.sp,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textLight,
                          size: 24.sp,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      filled: true,
                      fillColor: controller.isLoading
                          ? Theme.of(context).disabledColor.withOpacity(0.05)
                          : Theme.of(context).cardColor,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),

                // Forgot Password
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppText.forgotPassword,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Login Button
                Obx(
                  () => PrimaryButton(
                    text: AppText.signIn,
                    onPressed: controller.login,
                    isLoading: controller.isLoading,
                  ),
                ),
                SizedBox(height: 60.h),

                // Enterprise Setup Footer
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        AppText.enterpriseSetup,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),
                SizedBox(height: 24.h),
                Center(
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.ORGANIZATION_SETUP),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.domain_add_outlined,
                            color: const Color(0xFF475569),
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            AppText.setUpOrganization,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedLoginLogo extends StatefulWidget {
  const AnimatedLoginLogo({Key? key}) : super(key: key);

  @override
  State<AnimatedLoginLogo> createState() => _AnimatedLoginLogoState();
}

class _AnimatedLoginLogoState extends State<AnimatedLoginLogo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  // Title
  final List<String> _letters = ['C', 'a', 's', 'h', 'o', 'r', 'a'];
  final List<Animation<double>> _letterFadeAnimations = [];
  final List<Animation<double>> _letterSlideAnimations = [];

  // Subtitle
  final String _subtitleText = 'Smart petty cash';
  late List<String> _subtitleLetters;
  final List<Animation<double>> _subFadeAnimations = [];
  final List<Animation<double>> _subSlideAnimations = [];

  @override
  void initState() {
    super.initState();
    _subtitleLetters = _subtitleText.split('');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Loop duration
    )..repeat(); // Keep animating

    // --- Title Animations ---
    double startTime = 0.0;
    double step = 0.08;

    for (int i = 0; i < _letters.length; i++) {
      double start = startTime + (i * step); // e.g. 0.0, 0.08, 0.16...

      // Fade In
      _letterFadeAnimations.add(
        TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 10,
          ), // Fade In
          TweenSequenceItem(
            tween: ConstantTween<double>(1.0),
            weight: 60,
          ), // Stay Visible
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            weight: 10,
          ), // Fade Out
          TweenSequenceItem(
            tween: ConstantTween<double>(0.0),
            weight: 20,
          ), // Stay Hidden
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, 1.0, curve: Curves.linear),
          ),
        ),
      );

      // Slide In
      _letterSlideAnimations.add(
        TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 10.0,
              end: 0.0,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 10,
          ),
          TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 90),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: Interval(start, 1.0)),
        ),
      );
    }

    // --- Subtitle Animations (Slightly Delayed) ---
    // Start slightly after the title starts appearing
    double subStartTime = 0.2; // Start after 0.2s relative time
    double subStep = 0.03; // Faster ripple for subtitle

    for (int i = 0; i < _subtitleLetters.length; i++) {
      double start = subStartTime + (i * subStep);
      // Ensure start is < 1.0. If not, clamp or wrap, but with 16 chars * 0.03 = 0.48 + 0.2 = 0.68, so it fits.

      // Fade In
      _subFadeAnimations.add(
        TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 10,
          ), // Fade In
          TweenSequenceItem(
            tween: ConstantTween<double>(1.0),
            weight: 60,
          ), // Stay Visible
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            weight: 10,
          ), // Fade Out
          TweenSequenceItem(
            tween: ConstantTween<double>(0.0),
            weight: 20,
          ), // Stay Hidden
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, 1.0, curve: Curves.linear),
          ),
        ),
      );

      // Slide In
      _subSlideAnimations.add(
        TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 8.0,
              end: 0.0,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 10,
          ),
          TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 90),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: Interval(start, 1.0)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stable Shield
        Image.asset(
          'assets/images/cashora_shield.png',
          height: 65.h, // Increased from 50
        ),
        SizedBox(width: 16.w), // Increased spacing
        // Text Column (Name + Subtitle)
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Name
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row
                    Row(
                      children: List.generate(_letters.length, (index) {
                        return Opacity(
                          opacity: _letterFadeAnimations[index].value,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              _letterSlideAnimations[index].value,
                            ),
                            child: Text(
                              _letters[index],
                              style: GoogleFonts.outfit(
                                fontSize: 42.sp, // Increased from 34
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: -1.0,
                                height: 1.0,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    // Animated Subtitle Row
                    Padding(
                      padding: EdgeInsets.only(left: 2.w, top: 2.h),
                      child: Row(
                        children: List.generate(_subtitleLetters.length, (
                          index,
                        ) {
                          return Opacity(
                            opacity: _subFadeAnimations[index].value,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                _subSlideAnimations[index].value,
                              ),
                              child: Text(
                                _subtitleLetters[index],
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp, // Slightly smaller/stable
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF2D1B69),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
