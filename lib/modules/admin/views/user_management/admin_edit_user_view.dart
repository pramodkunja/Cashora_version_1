import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/admin_user_controller.dart';
import 'widgets/admin_edit_user_background.dart';
import 'widgets/admin_edit_user_form.dart';
import 'widgets/admin_edit_user_hero.dart';
import 'widgets/admin_edit_user_top_bar.dart';

/// Admin → Edit User. Lavender-theme variant matching departments,
/// add-user, and user-list pages.
class AdminEditUserView extends GetView<AdminUserController> {
  const AdminEditUserView({super.key});

  static const Color _bgB = Color(0xFFF8F7FF);

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _bgB,
      resizeToAvoidBottomInset: true,
      body: Obx(() {
        final user = Map<String, dynamic>.from(controller.rxSelectedUser);
        if (user.isEmpty) {
          return Stack(
            children: [
              const AdminEditUserBackground(),
              SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    const AdminEditUserTopBar(),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: const SkeletonListView(itemCount: 5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        String name =
            (user['full_name'] ??
                    user['name'] ??
                    '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}')
                .toString()
                .trim();
        if (name.isEmpty) name = 'Unknown User';
        final email = (user['email'] ?? '').toString();
        final isActive = user['isActive'] ?? user['is_active'] ?? true;

        return Stack(
          children: [
            const AdminEditUserBackground(),
            SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  const AdminEditUserTopBar(),
                  AdminEditUserHero(
                    name: name,
                    email: email,
                    isActive: isActive,
                  ),
                  Expanded(
                    child: AdminEditUserForm(
                      controller: controller,
                      bottomInset: bottomInset,
                      isActive: isActive,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
