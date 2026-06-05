import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../controllers/department_controller.dart';
import 'widgets/department_background_layer.dart';
import 'widgets/department_card.dart';
import 'widgets/department_hero_block.dart';
import 'widgets/department_states.dart';
import 'widgets/department_top_bar.dart';

class DepartmentListView extends GetView<DepartmentController> {
  const DepartmentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DepartmentBackgroundLayer.bgB,
      body: Stack(
        children: [
          const DepartmentBackgroundLayer(),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                DepartmentTopBar(controller: controller),
                DepartmentHeroBlock(controller: controller),
                Expanded(child: _buildListArea()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: DepartmentGradientFab(controller: controller),
    );
  }

  // ── White rounded sheet that hosts the list / skeleton / empty / error
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
            color: AppColors.primary.withOpacity(0.10),
            blurRadius: 24.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value && controller.departments.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: const SkeletonListView(),
          );
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.departments.isEmpty) {
          return DepartmentErrorState(controller: controller);
        }
        if (controller.departments.isEmpty) {
          return const DepartmentEmptyState();
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchDepartments,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 110.h),
            itemCount: controller.departments.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (_, i) => DepartmentCard(
              dept: controller.departments[i],
              controller: controller,
            ),
          ),
        );
      }),
    );
  }
}
