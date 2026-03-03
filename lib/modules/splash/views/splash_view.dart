import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _contentWidthAnimation;
  late Animation<double> _taglineOpacityAnimation;

  // Staggered letter animations
  final List<String> _letters = ['C', 'a', 's', 'h', 'o', 'r', 'a'];
  final List<Animation<double>> _letterFadeAnimations = [];
  final List<Animation<double>> _letterSlideAnimations = [];

  final SplashController controller = Get.find<SplashController>();

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 1. Logo Scale: Large to Normal (0.0 - 0.8s)
    _logoScaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Expand Space for Text (Logo Moves Left) (0.8s - 1.5s)
    // Width grows to accommodate text (~240px)
    _contentWidthAnimation = Tween<double>(begin: 0.0, end: 200.w).animate(
      // Responsive width
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.5, curve: Curves.easeInOut),
      ),
    );

    // 3. Letters Reveal One by One (1.2s - 2.2s)
    // Overlapping slightly with the movement
    double startTime = 0.4;
    double step = 0.05; // Quick staggering
    for (int i = 0; i < _letters.length; i++) {
      double start = startTime + (i * step);
      double end = start + 0.1;

      _letterFadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Interval(start, end, curve: Curves.easeIn),
          ),
        ),
      );

      _letterSlideAnimations.add(
        Tween<double>(begin: 10.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
    }

    // 4. Tagline Reveal (2.2s - 2.8s)
    _taglineOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Logo
                Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: Image.asset(
                    'assets/images/cashora_shield.png',
                    width: 120.w, // Responsive width
                  ),
                ),

                // Expanding Text Area
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 200.w,
                  ), // Constrain max width
                  width: _contentWidthAnimation.value,
                  height: 100.h,
                  child: ClipRect(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.0.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Letter by Letter
                            Row(
                              children: List.generate(_letters.length, (index) {
                                // As before...
                                return Opacity(
                                  opacity: _letterFadeAnimations.isNotEmpty
                                      ? _letterFadeAnimations[index].value
                                      : 0.0,
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      _letterSlideAnimations.isNotEmpty
                                          ? _letterSlideAnimations[index].value
                                          : 0.0,
                                    ),
                                    child: Text(
                                      _letters[index],
                                      style: GoogleFonts.outfit(
                                        fontSize: 48.sp,
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
                            SizedBox(height: 4.h),
                            // Tagline
                            Opacity(
                              opacity: _taglineOpacityAnimation.value,
                              child: Text(
                                'Smart petty cash',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
