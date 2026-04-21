import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/app_text.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo + Branding ──────────────────────────────
                  const AnimatedLoginLogo(),
                  SizedBox(height: 32.h),

                  // ── Form Card ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 32.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          AppText.welcomeBack,
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          AppText.signInSubtitle,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF94A3B8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 28.h),

                        // Email
                        _buildLabel('Email Address'),
                        SizedBox(height: 8.h),
                        Obx(
                          () => TextField(
                            controller: controller.emailController,
                            enabled: !controller.isLoading,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: _inputDecoration(
                              context,
                              hint: 'name@company.com',
                              icon: Icons.email_outlined,
                              disabled: controller.isLoading,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Password
                        _buildLabel('Password'),
                        SizedBox(height: 8.h),
                        Obx(
                          () => TextField(
                            controller: controller.passwordController,
                            obscureText: !controller.isPasswordVisible.value,
                            enabled: !controller.isLoading,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => controller.login(),
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: _inputDecoration(
                              context,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              disabled: controller.isLoading,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF94A3B8),
                                  size: 20.sp,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                        ),

                        // Forgot Password
                        SizedBox(height: 8.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppText.forgotPassword,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Sign In Button
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.primary.withOpacity(0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: controller.isLoading
                                  ? SizedBox(
                                      height: 22.h,
                                      width: 22.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      AppText.signIn,
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Enterprise Setup Footer ──────────────────────
                  SizedBox(height: 40.h),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Color(0xFFCBD5E1)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          AppText.enterpriseSetup,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Color(0xFFCBD5E1)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Setup Org Button — outlined grey pill
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Get.toNamed(AppRoutes.ORGANIZATION_SETUP),
                      icon: Icon(
                        Icons.domain_add_outlined,
                        size: 20.sp,
                        color: const Color(0xFF64748B),
                      ),
                      label: Text(
                        AppText.setUpOrganization,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
    bool disabled = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 14.sp,
        color: const Color(0xFFCBD5E1),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20.sp),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: disabled ? const Color(0xFFF8FAFC) : Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
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
  final List<String> _letters = ['C', 'a', 's', 'h', 'o', 'r', 'a'];
  final List<Animation<double>> _letterFadeAnimations = [];
  final List<Animation<double>> _letterSlideAnimations = [];

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
      duration: const Duration(seconds: 4),
    )..repeat();

    double step = 0.08;
    for (int i = 0; i < _letters.length; i++) {
      double start = i * step;
      _letterFadeAnimations.add(
        TweenSequence([
          TweenSequenceItem(
              tween: Tween<double>(begin: 0.0, end: 1.0), weight: 10),
          TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 60),
          TweenSequenceItem(
              tween: Tween<double>(begin: 1.0, end: 0.0), weight: 10),
          TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 20),
        ]).animate(CurvedAnimation(
            parent: _controller, curve: Interval(start, 1.0))),
      );
      _letterSlideAnimations.add(
        TweenSequence([
          TweenSequenceItem(
              tween: Tween<double>(begin: 10.0, end: 0.0)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 10),
          TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 90),
        ]).animate(CurvedAnimation(
            parent: _controller, curve: Interval(start, 1.0))),
      );
    }

    double subStart = 0.2;
    double subStep = 0.03;
    for (int i = 0; i < _subtitleLetters.length; i++) {
      double start = subStart + (i * subStep);
      _subFadeAnimations.add(
        TweenSequence([
          TweenSequenceItem(
              tween: Tween<double>(begin: 0.0, end: 1.0), weight: 10),
          TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 60),
          TweenSequenceItem(
              tween: Tween<double>(begin: 1.0, end: 0.0), weight: 10),
          TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 20),
        ]).animate(CurvedAnimation(
            parent: _controller, curve: Interval(start, 1.0))),
      );
      _subSlideAnimations.add(
        TweenSequence([
          TweenSequenceItem(
              tween: Tween<double>(begin: 8.0, end: 0.0)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 10),
          TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 90),
        ]).animate(CurvedAnimation(
            parent: _controller, curve: Interval(start, 1.0))),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/cashora_shield.png', height: 56.h),
            SizedBox(width: 12.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(_letters.length, (i) {
                    return Opacity(
                      opacity: _letterFadeAnimations[i].value,
                      child: Transform.translate(
                        offset: Offset(0, _letterSlideAnimations[i].value),
                        child: Text(
                          _letters[i],
                          style: GoogleFonts.outfit(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.w, top: 2.h),
                  child: Row(
                    children: List.generate(_subtitleLetters.length, (i) {
                      return Opacity(
                        opacity: _subFadeAnimations[i].value,
                        child: Transform.translate(
                          offset: Offset(0, _subSlideAnimations[i].value),
                          child: Text(
                            _subtitleLetters[i],
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              height: 1.2,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
