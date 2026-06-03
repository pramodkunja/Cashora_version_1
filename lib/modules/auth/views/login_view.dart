import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  // ── Light palette tuned for this screen ───────────────────────────────
  // Top hero zone uses a soft lavender gradient → fades into the white
  // sheet below. Same `AppColors.primary` / `AppColors.primaryLight` for
  // every accent (button, focus, decorations).
  static const Color _bgA = Color(0xFFF0E9FF); // top
  static const Color _bgB = Color(0xFFF8F7FF); // mid
  static const Color _bgC = Color(0xFFEEF2FF); // bottom

  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink700 = Color(0xFF334155);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _ink200 = Color(0xFFE2E8F0);
  static const Color _surface = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    // bottom inset is read once and passed into the sheet so content clears
    // the home-indicator / gesture bar even though the sheet itself extends
    // all the way to the bottom edge.
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _bgB,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _backgroundLayer(),
          // SafeArea only on the TOP — the white sheet should fill to the
          // bottom of the screen instead of stopping above the home bar.
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                _buildHeroZone(),
                Expanded(child: _buildWhiteSheet(bottomInset)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── BACKGROUND ─────────────────────────

  Widget _backgroundLayer() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgA, _bgB, _bgC],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Soft corner blooms — concentrated in the top hero zone for visual
        // depth. Third bloom on the right-mid adds asymmetry/richness.
        Positioned(
          top: -90.h,
          right: -70.w,
          child: _bloom(280.w, AppColors.primary, 0.20),
        ),
        Positioned(
          top: 40.h,
          left: -60.w,
          child: _bloom(200.w, AppColors.primaryLight, 0.28),
        ),
        Positioned(
          top: 140.h,
          right: -30.w,
          child: _bloom(140.w, AppColors.primaryLight, 0.22),
        ),
      ],
    );
  }

  Widget _bloom(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  // ─────────────────── TOP HERO ZONE (light) ────────────────────

  Widget _buildHeroZone() {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 20.h, 28.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _entranceWrap(
            duration: const Duration(milliseconds: 600),
            child: _buildBrandLockup(),
          ),
          SizedBox(height: 26.h),
          _entranceWrap(
            duration: const Duration(milliseconds: 800),
            child: Text(
              'Welcome back.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 38.sp,
                fontWeight: FontWeight.w700,
                color: _ink900,
                letterSpacing: -1.2,
                height: 1.05,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          _entranceWrap(
            duration: const Duration(milliseconds: 1000),
            child: Text(
              'Sign in to manage your petty cash workspace.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: _ink500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLockup() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Shield in a gradient circle, wrapped in a subtle accent ring.
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1.4,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/cashora_shield.png',
              width: 28.w,
              height: 28.w,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cashora',
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Smart petty cash',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _ink500,
                letterSpacing: 0.2,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────── WHITE SHEET (form) ────────────────────────

  Widget _buildWhiteSheet(double bottomInset) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(42.r),
          topRight: Radius.circular(42.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 28.r,
            offset: Offset(0, -10.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        // Bottom padding includes the system inset so the last form element
        // doesn't collide with the home indicator / gesture bar.
        padding: EdgeInsets.fromLTRB(26.w, 14.h, 26.w, 26.h + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sheet handle — small ergonomic detail
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: _ink200,
                  borderRadius: BorderRadius.circular(2.h),
                ),
              ),
            ),
            SizedBox(height: 22.h),
            _entranceWrap(
              duration: const Duration(milliseconds: 900),
              child: Text(
                'Sign in to continue',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: _ink900,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            _entranceWrap(
              duration: const Duration(milliseconds: 1000),
              child: Text(
                'Use your work email to access the dashboard.',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: _ink500,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            _entranceWrap(
              duration: const Duration(milliseconds: 1050),
              child: Obx(
                () => TextField(
                  controller: controller.emailController,
                  enabled: !controller.isLoading,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
                  cursorColor: AppColors.primary,
                  decoration: _floatingLabelDecoration(
                    label: 'Email address',
                    icon: Icons.mail_outline_rounded,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            _entranceWrap(
              duration: const Duration(milliseconds: 1100),
              child: Obx(
                () => TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  enabled: !controller.isLoading,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => controller.login(),
                  style: GoogleFonts.inter(fontSize: 14.sp, color: _ink900),
                  cursorColor: AppColors.primary,
                  decoration: _floatingLabelDecoration(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _ink500,
                        size: 20.sp,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),
            _entranceWrap(
              duration: const Duration(milliseconds: 1150),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 4.w, vertical: 4.h),
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
            ),
            SizedBox(height: 18.h),

            _entranceWrap(
              duration: const Duration(milliseconds: 1200),
              child: _buildSignInButton(),
            ),

            SizedBox(height: 22.h),

            _entranceWrap(
              duration: const Duration(milliseconds: 1300),
              child: _buildOrDivider(),
            ),
            SizedBox(height: 18.h),

            _entranceWrap(
              duration: const Duration(milliseconds: 1400),
              child: _buildSetupOrgButton(),
            ),
            SizedBox(height: 24.h),

            _entranceWrap(
              duration: const Duration(milliseconds: 1500),
              child: Center(
                child: Text(
                  'Need help signing in? Contact your admin.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: _ink500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── BUTTONS ─────────────────────────

  Widget _buildSignInButton() {
    return Obx(() {
      final bool busy = controller.isLoading;
      return Container(
        height: 56.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: busy
                ? [
                    AppColors.primary.withValues(alpha: 0.55),
                    AppColors.primaryLight.withValues(alpha: 0.55),
                  ]
                : [AppColors.primary, AppColors.primaryLight],
          ),
          boxShadow: busy
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.40),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: busy ? null : controller.login,
            borderRadius: BorderRadius.circular(16.r),
            child: Center(
              child: busy
                  ? SizedBox(
                      height: 22.h,
                      width: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppText.signIn,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18.sp),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: _ink200)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: _ink500,
              letterSpacing: 1.6,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: _ink200)),
      ],
    );
  }

  Widget _buildSetupOrgButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        onPressed: () => Get.toNamed(AppRoutes.ORGANIZATION_SETUP),
        icon: Icon(Icons.domain_add_outlined, size: 20.sp, color: _ink700),
        label: Text(
          AppText.setUpOrganization,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: _ink700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _ink200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          backgroundColor: _surface,
        ),
      ),
    );
  }

  // ───────────────────── DECORATIONS / HELPERS ─────────────────────

  InputDecoration _floatingLabelDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: _ink500,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: 12.w, right: 8.w),
        child: Icon(icon, color: _ink500, size: 20.sp),
      ),
      prefixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
      suffixIcon: suffix,
      filled: true,
      fillColor: _surface,
      contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _ink200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _ink200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _ink200),
      ),
    );
  }

  Widget _entranceWrap({required Widget child, required Duration duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, t, c) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
