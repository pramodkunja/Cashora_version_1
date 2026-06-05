import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';

/// Centered splash hero: shield with three expanding sonar rings, the
/// letter-by-letter "Cashora" wordmark, and the tagline pill.
class SplashHero extends StatelessWidget {
  const SplashHero({
    super.key,
    required this.reveal,
    required this.loop,
    required this.logoFade,
    required this.logoScale,
    required this.letters,
    required this.letterFade,
    required this.letterRise,
    required this.taglineFade,
  });

  final Animation<double> reveal;
  final Animation<double> loop;
  final Animation<double> logoFade;
  final Animation<double> logoScale;
  final List<String> letters;
  final List<Animation<double>> letterFade;
  final List<Animation<double>> letterRise;
  final Animation<double> taglineFade;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: reveal,
      builder: (context, _) {
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
                  _SonarRing(loop: loop, phaseOffset: 0.0),
                  _SonarRing(loop: loop, phaseOffset: 0.33),
                  _SonarRing(loop: loop, phaseOffset: 0.66),
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
                    opacity: logoFade.value,
                    child: Transform.scale(
                      scale: logoScale.value,
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
              children: List.generate(letters.length, (i) {
                return Opacity(
                  opacity: letterFade[i].value,
                  child: Transform.translate(
                    offset: Offset(0, letterRise[i].value),
                    child: Text(
                      letters[i],
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
              opacity: taglineFade.value,
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
      },
    );
  }
}

class _SonarRing extends StatelessWidget {
  const _SonarRing({required this.loop, required this.phaseOffset});

  final Animation<double> loop;
  final double phaseOffset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (context, _) {
        final t = (loop.value + phaseOffset) % 1.0;
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
}
