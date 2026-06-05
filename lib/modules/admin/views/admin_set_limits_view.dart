import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/admin_set_limits_controller.dart';
import 'widgets/admin_set_limits_actions.dart';
import 'widgets/admin_set_limits_background.dart';
import 'widgets/admin_set_limits_form.dart';
import 'widgets/admin_set_limits_hero.dart';
import 'widgets/admin_set_limits_top_bar.dart';

class AdminSetLimitsView extends GetView<AdminSetLimitsController> {
  const AdminSetLimitsView({super.key});

  // ── Palette (matches departments + add-user + user-list) ──────────────
  static const Color _bgB = Color(0xFFF8F7FF);

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _bgB,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AdminSetLimitsBackground(),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                const AdminSetLimitsTopBar(),
                const AdminSetLimitsHero(),
                Expanded(child: _buildContentSheet(bottomInset)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── CONTENT SHEET ───────────────────

  Widget _buildContentSheet(double bottomInset) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36.r),
          topRight: Radius.circular(36.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 24.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 24.h + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminSetLimitsForm(controller: controller),
            SizedBox(height: 28.h),
            AdminSetLimitsActions(controller: controller),
          ],
        ),
      ),
    );
  }
}
