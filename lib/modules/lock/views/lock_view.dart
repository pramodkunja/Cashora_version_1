import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../utils/app_colors.dart';
import '../../../../routes/app_routes.dart';

class LockView extends StatefulWidget {
  const LockView({super.key});

  @override
  State<LockView> createState() => _LockViewState();
}

class _LockViewState extends State<LockView>
    with TickerProviderStateMixin {
  final BiometricService _biometricService = Get.find<BiometricService>();
  final AuthService _authService = Get.find<AuthService>();

  // Breathing halo behind the fingerprint icon. Loops indefinitely.
  late AnimationController _halo;
  late Animation<double> _haloAnim;

  @override
  void initState() {
    super.initState();
    _halo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _haloAnim = Tween<double>(begin: 0.30, end: 1.0).animate(
      CurvedAnimation(parent: _halo, curve: Curves.easeInOut),
    );
    // Auto-prompt biometric shortly after the view mounts so the user
    // doesn't have to tap on first appearance.
    Future.delayed(const Duration(milliseconds: 280), _authenticate);
  }

  @override
  void dispose() {
    _halo.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final bool ok = await _biometricService.authenticate();
    if (ok) {
      _authService.verifySession();
      Get.offAllNamed(AppRoutes.INITIAL);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0B25),
        body: Stack(
          children: [
            _backgroundLayer(),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(color: Colors.transparent),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  children: [
                    const Spacer(),
                    _entranceWrap(
                      duration: const Duration(milliseconds: 700),
                      child: _buildHero(),
                    ),
                    SizedBox(height: 32.h),
                    _entranceWrap(
                      duration: const Duration(milliseconds: 900),
                      child: _buildHeader(),
                    ),
                    const Spacer(),
                    _entranceWrap(
                      duration: const Duration(milliseconds: 1100),
                      child: _buildUnlockButton(),
                    ),
                    SizedBox(height: 18.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backgroundLayer() {
    return Stack(
      children: [
        // Deep purple base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B1140), Color(0xFF0F0B25)],
            ),
          ),
        ),
        Positioned(
          top: -100.h,
          right: -80.w,
          child: _blob(320.w, AppColors.primary, 0.55),
        ),
        Positioned(
          bottom: -120.h,
          left: -90.w,
          child: _blob(340.w, AppColors.primaryLight, 0.40),
        ),
        Positioned(
          top: 220.h,
          left: -60.w,
          child: _blob(180.w, AppColors.primaryLight, 0.30),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color, double opacity) {
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

  Widget _buildHero() {
    return SizedBox(
      width: 200.w,
      height: 200.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer breathing halo
          AnimatedBuilder(
            animation: _halo,
            builder: (context, _) {
              return Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight
                          .withValues(alpha: 0.35 * _haloAnim.value),
                      AppColors.primaryLight.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              );
            },
          ),
          // Glassy ring
          Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.2,
              ),
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          // Fingerprint badge
          Container(
            width: 96.w,
            height: 96.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 28.r,
                  offset: Offset(0, 14.h),
                ),
              ],
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: 50.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'SESSION LOCKED',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 1.4,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'Welcome back',
          style: GoogleFonts.inter(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          "Confirm it's you to continue",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.70),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUnlockButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _authenticate,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open_rounded,
                    color: Colors.white, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  'Unlock',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
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
            offset: Offset(0, 24 * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
