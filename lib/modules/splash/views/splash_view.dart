import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  // Light lavender palette — slightly more saturated than the previous
  // version so the sonar rings and particles read clearly.
  static const Color _bgA = Color(0xFFF0E9FF); // top — light lavender
  static const Color _bgB = Color(0xFFF8F7FF); // mid
  static const Color _bgC = Color(0xFFEEF2FF); // bottom — light indigo
  static const Color _ink500 = Color(0xFF64748B);
  static const Color _track = Color(0xFFE2E1F5);

  // Main reveal animation, 2400 ms. Holds at 1.0; controller navigates
  // ~200 ms later (total ≈ 2600 ms — matches SplashController timing).
  late AnimationController _ctrl;
  // Continuously looping background animations (sonar rings, particles).
  late AnimationController _loop;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _taglineFade;
  late Animation<double> _loaderFade;

  final List<String> _letters = ['C', 'a', 's', 'h', 'o', 'r', 'a'];
  final List<Animation<double>> _letterFade = [];
  final List<Animation<double>> _letterRise = [];

  // Hand-placed floating particles. Each has a position factor (0..1 on
  // the screen) and a phase offset so they don't all pulse in sync.
  final List<_Particle> _particles = const [
    _Particle(dx: 0.10, dy: 0.18, size: 5, phase: 0.0),
    _Particle(dx: 0.85, dy: 0.12, size: 4, phase: 0.25),
    _Particle(dx: 0.18, dy: 0.78, size: 7, phase: 0.55),
    _Particle(dx: 0.92, dy: 0.72, size: 5, phase: 0.10),
    _Particle(dx: 0.50, dy: 0.08, size: 3, phase: 0.40),
    _Particle(dx: 0.07, dy: 0.55, size: 4, phase: 0.65),
    _Particle(dx: 0.95, dy: 0.45, size: 3, phase: 0.85),
    _Particle(dx: 0.62, dy: 0.92, size: 6, phase: 0.30),
    _Particle(dx: 0.32, dy: 0.30, size: 3, phase: 0.70),
  ];

  late final SplashController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SplashController>();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.22, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    const start = 0.28;
    const step = 0.055;
    for (int i = 0; i < _letters.length; i++) {
      final s = start + (i * step);
      final e = (s + 0.12).clamp(0.0, 1.0);
      _letterFade.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Interval(s, e, curve: Curves.easeOut),
          ),
        ),
      );
      _letterRise.add(
        Tween<double>(begin: 18.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Interval(s, e, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.70, 0.90, curve: Curves.easeIn),
      ),
    );
    _loaderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.72, 0.92, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgB,
      body: Stack(
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
          // Soft corner blooms — large, low-opacity
          Positioned(
            top: -90.h,
            right: -70.w,
            child: _bloom(300.w, AppColors.primary, 0.16),
          ),
          Positioned(
            bottom: -110.h,
            left: -90.w,
            child: _bloom(340.w, AppColors.primaryLight, 0.22),
          ),
          // Breathing particles in primary purple
          ..._particles.map((p) => _buildParticle(p, size)),
          // Centered hero
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => _buildHero(),
            ),
          ),
          // Bottom hairline loader
          Positioned(
            left: 32.w,
            right: 32.w,
            bottom: 56.h,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => Opacity(
                opacity: _loaderFade.value,
                child: _buildHairlineLoader(),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildParticle(_Particle p, Size size) {
    return Positioned(
      left: p.dx * size.width - p.size,
      top: p.dy * size.height - p.size,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, _) {
          final phaseShifted = (_loop.value + p.phase) % 1.0;
          final pulse = (sin(phaseShifted * pi * 2) + 1) / 2;
          final opacity = 0.18 + pulse * 0.42;
          final scale = 0.6 + pulse * 0.8;
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: p.size * 2,
                height: p.size * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shield with 3 expanding sonar rings behind it
        SizedBox(
          width: 220.w,
          height: 220.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildSonarRing(0.0),
              _buildSonarRing(0.33),
              _buildSonarRing(0.66),
              // Soft inner halo
              Container(
                width: 130.w,
                height: 130.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.30),
                      AppColors.primaryLight.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // Shield
              Opacity(
                opacity: _logoFade.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Image.asset(
                    'assets/images/cashora_shield.png',
                    width: 86.w,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        // Wordmark — letter-by-letter rise, in primary purple
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_letters.length, (i) {
            return Opacity(
              opacity: _letterFade[i].value,
              child: Transform.translate(
                offset: Offset(0, _letterRise[i].value),
                child: Text(
                  _letters[i],
                  style: GoogleFonts.outfit(
                    fontSize: 52.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -1.2,
                    height: 1.0,
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 14.h),
        // Tagline pill
        Opacity(
          opacity: _taglineFade.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Text(
              'SMART · PETTY · CASH',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 2.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSonarRing(double phaseOffset) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final t = (_loop.value + phaseOffset) % 1.0;
        final scale = 0.35 + t * 0.85;
        final opacity = (1.0 - t) * 0.45;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 220.w,
              height: 220.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHairlineLoader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            tween: Tween<double>(
              begin: 0,
              end: controller.progress.value,
            ),
            builder: (context, value, _) {
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: _track,
                      borderRadius: BorderRadius.circular(1.h),
                    ),
                  ),
                  // Fill with primary gradient + glow
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 2.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1.h),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.50),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'PREPARING YOUR WORKSPACE',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: _ink500,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;
  final double phase;
  const _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.phase,
  });
}
