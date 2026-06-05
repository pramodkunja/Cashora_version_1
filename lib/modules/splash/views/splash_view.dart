import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/splash_controller.dart';
import 'widgets/splash_background.dart';
import 'widgets/splash_hero.dart';
import 'widgets/splash_loader.dart';

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
          SplashBackground(
            loop: _loop,
            size: size,
            bgA: _bgA,
            bgB: _bgB,
            bgC: _bgC,
          ),
          // Centered hero
          Center(
            child: SplashHero(
              reveal: _ctrl,
              loop: _loop,
              logoFade: _logoFade,
              logoScale: _logoScale,
              letters: _letters,
              letterFade: _letterFade,
              letterRise: _letterRise,
              taglineFade: _taglineFade,
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
                child: SplashLoader(
                  controller: controller,
                  trackColor: _track,
                  labelColor: _ink500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
