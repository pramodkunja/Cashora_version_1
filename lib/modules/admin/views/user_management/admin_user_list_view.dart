import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../controllers/admin_user_controller.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import 'widgets/admin_user_list_background.dart';
import 'widgets/admin_user_list_top_bar.dart';
import 'widgets/admin_user_list_hero.dart';
import 'widgets/admin_user_list_search_bar.dart';
import 'widgets/admin_user_list_card.dart';
import 'widgets/admin_user_list_empty.dart';
import 'widgets/admin_user_list_fab.dart';

class AdminUserListView extends GetView<AdminUserController> {
  const AdminUserListView({super.key});

  static const Color _bgB = Color(0xFFF8F7FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgB,
      body: Stack(
        children: [
          const AdminUserListBackground(),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                AdminUserListTopBar(
                  onBack: () => Get.back(),
                  onRefresh: controller.fetchUsers,
                ),
                AdminUserListHero(controller: controller),
                Expanded(child: _buildListArea()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AdminUserListFab(onTap: controller.addUser),
    );
  }

  // ─────────────────── LIST AREA (white sheet) ───────────────────

  Widget _buildListArea() {
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
      child: Obx(() {
        if (controller.isLoadingUsers.value) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: const SkeletonListView(),
          );
        }
        if (controller.rxUsers.isEmpty) {
          return AdminUserListEmpty(onRetry: controller.fetchUsers);
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchUsers,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
                  child: const AdminUserListSearchBar(),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 6.h),
                sliver: SliverToBoxAdapter(
                  child: Obx(() => Text(
                        'ALL USERS · ${controller.rxUsers.length}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      )),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 110.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: AdminUserListCard(
                        user: controller.rxUsers[i],
                        onTap: () => controller.editUser(controller.rxUsers[i]),
                      ),
                    ),
                    childCount: controller.rxUsers.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
