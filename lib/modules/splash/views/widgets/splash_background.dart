import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';

/// A floating particle hand-placed on the splash background.
class SplashParticle {
  final double dx;
  final double dy;
  final double size;
  final double phase;
  const SplashParticle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.phase,
  });
}

/// Default particle set used on the splash screen.
const List<SplashParticle> kSplashParticles = <SplashParticle>[
  SplashParticle(dx: 0.10, dy: 0.18, size: 5, phase: 0.0),
  SplashParticle(dx: 0.85, dy: 0.12, size: 4, phase: 0.25),
  SplashParticle(dx: 0.18, dy: 0.78, size: 7, phase: 0.55),
  SplashParticle(dx: 0.92, dy: 0.72, size: 5, phase: 0.10),
  SplashParticle(dx: 0.50, dy: 0.08, size: 3, phase: 0.40),
  SplashParticle(dx: 0.07, dy: 0.55, size: 4, phase: 0.65),
  SplashParticle(dx: 0.95, dy: 0.45, size: 3, phase: 0.85),
  SplashParticle(dx: 0.62, dy: 0.92, size: 6, phase: 0.30),
  SplashParticle(dx: 0.32, dy: 0.30, size: 3, phase: 0.70),
];

/// Soft lavender gradient + corner blooms + breathing particles that sit
/// behind the splash hero. Driven by [loop] which must be a continuously
/// repeating animation controller.
class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    required this.loop,
    required this.size,
    this.particles = kSplashParticles,
    this.bgA = const Color(0xFFF0E9FF),
    this.bgB = const Color(0xFFF8F7FF),
    this.bgC = const Color(0xFFEEF2FF),
  });

  final Animation<double> loop;
  final Size size;
  final List<SplashParticle> particles;
  final Color bgA;
  final Color bgB;
  final Color bgC;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgA, bgB, bgC],
              stops: const [0.0, 0.5, 1.0],
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
        ...particles.map((p) => _buildParticle(p, size)),
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
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(SplashParticle p, Size size) {
    return Positioned(
      left: p.dx * size.width - p.size,
      top: p.dy * size.height - p.size,
      child: AnimatedBuilder(
        animation: loop,
        builder: (context, _) {
          final phaseShifted = (loop.value + p.phase) % 1.0;
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
}
