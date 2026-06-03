import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../routes/app_routes.dart';

class ResetPasswordSuccessView extends StatelessWidget {
  const ResetPasswordSuccessView({super.key});

  static const Color _bgTop = Color(0xFFF8F7FF);
  static const Color _bgBottom = Color(0xFFEEF2FF);
  static const Color _ink900 = Color(0xFF0F172A);
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _green = AppColors.successGreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _backgroundLayer(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
              child: Column(
                children: [
                  const Spacer(),
                  _AnimatedCheckmark(),
                  SizedBox(height: 32.h),
                  _entranceWrap(
                    duration: const Duration(milliseconds: 1000),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'ALL SET',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: _green,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _entranceWrap(
                    duration: const Duration(milliseconds: 1100),
                    child: Text(
                      AppText.passwordUpdatedSuccess,
                      style: GoogleFonts.inter(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: _ink900,
                        height: 1.15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _entranceWrap(
                    duration: const Duration(milliseconds: 1200),
                    child: Text(
                      'You can now sign in with your new password.',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: _ink500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  _entranceWrap(
                    duration: const Duration(milliseconds: 1400),
                    child: _buildPrimaryButton(),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundLayer() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgTop, _bgBottom],
            ),
          ),
        ),
        Positioned(
          top: -80.h,
          right: -60.w,
          child: _blob(260.w, _green, 0.16),
        ),
        Positioned(
          bottom: -100.h,
          left: -80.w,
          child: _blob(300.w, AppColors.primaryLight, 0.20),
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

  Widget _buildPrimaryButton() {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.offAllNamed(AppRoutes.LOGIN),
          borderRadius: BorderRadius.circular(14.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppText.backToLogin,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
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
            offset: Offset(0, 22 * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

/// Big circular success badge with an animated scale-in checkmark and a
/// pulsing halo. Self-contained — no parent controller needed.
class _AnimatedCheckmark extends StatefulWidget {
  @override
  State<_AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<_AnimatedCheckmark>
    with TickerProviderStateMixin {
  late AnimationController _scale;
  late AnimationController _halo;
  late Animation<double> _scaleAnim;
  late Animation<double> _haloAnim;

  static const Color _green = AppColors.successGreen;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _halo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnim = CurvedAnimation(
      parent: _scale,
      curve: Curves.elasticOut,
    );
    _haloAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _halo, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    _halo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.w,
      height: 200.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing halo
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
                      _green.withValues(alpha: 0.28 * _haloAnim.value),
                      _green.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              );
            },
          ),
          // Inner solid badge
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.successGreen,
                    Color(0xFF34D399),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _green.withValues(alpha: 0.45),
                    blurRadius: 28.r,
                    offset: Offset(0, 14.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 64.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
