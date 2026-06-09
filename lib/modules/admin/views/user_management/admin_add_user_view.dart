import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_user_controller.dart';
import 'widgets/admin_add_user_background.dart';
import 'widgets/admin_add_user_form.dart';
import 'widgets/admin_add_user_hero.dart';
import 'widgets/admin_add_user_top_bar.dart';

class AdminAddUserView extends GetView<AdminUserController> {
  const AdminAddUserView({super.key});

  // ── Light palette (matches login/auth language) ───────────────────────
  static const Color _bgB = Color(0xFFF8F7FF);

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bgB,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AdminAddUserBackground(),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                const AdminAddUserTopBar(),
                const AdminAddUserHero(),
                Expanded(
                  child: AdminAddUserForm(
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
