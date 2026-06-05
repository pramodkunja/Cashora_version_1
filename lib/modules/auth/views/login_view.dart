import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'widgets/login_background.dart';
import 'widgets/login_form_section.dart';
import 'widgets/login_hero_zone.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  // ── Light palette tuned for this screen ───────────────────────────────
  // Top hero zone uses a soft lavender gradient → fades into the white
  // sheet below. Same `AppColors.primary` / `AppColors.primaryLight` for
  // every accent (button, focus, decorations).
  static const Color _bgB = Color(0xFFF8F7FF); // mid

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
          const LoginBackground(),
          // SafeArea only on the TOP — the white sheet should fill to the
          // bottom of the screen instead of stopping above the home bar.
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                const LoginHeroZone(),
                Expanded(
                  child: LoginFormSection(
                    controller: controller,
                    bottomInset: bottomInset,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
