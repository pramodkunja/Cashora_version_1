import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../controllers/category_controller.dart';
import 'widgets/category_card.dart';
import 'widgets/category_hero_block.dart';
import 'widgets/category_states.dart';
import 'widgets/category_top_bar.dart';
import 'widgets/department_background_layer.dart';

/// Admin screen for managing expense categories. Mirrors
/// [DepartmentListView] — same background, hero pattern, list card
/// layout, FAB.
class CategoryListView extends GetView<CategoryController> {
  const CategoryListView({super.key});

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
                CategoryTopBar(controller: controller),
                CategoryHeroBlock(controller: controller),
                Expanded(child: _buildListArea()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: CategoryGradientFab(controller: controller),
    );
  }

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
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: const SkeletonListView(),
          );
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.categories.isEmpty) {
          return CategoryErrorState(controller: controller);
        }
        if (controller.categories.isEmpty) {
          return const CategoryEmptyState();
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchCategories,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 110.h),
            itemCount: controller.categories.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (_, i) => CategoryCard(
              category: controller.categories[i],
              controller: controller,
            ),
          ),
        );
      }),
    );
  }
}
