import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/my_requests_controller.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_colors.dart';
import '../../../utils/widgets/skeletons/skeleton_loader.dart';
import 'widgets/my_requests_header.dart';
import 'widgets/my_requests_filter_chips.dart';
import 'widgets/my_requests_card.dart';
import 'widgets/my_requests_empty_state.dart';

class MyRequestsView extends GetView<MyRequestsController> {
  const MyRequestsView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          MyRequestsHeader(controller: controller),
          _buildSearch(),
          SizedBox(height: 12.h),
          MyRequestsFilterChips(controller: controller),
          SizedBox(height: 14.h),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const SkeletonListView();
              }
              if (controller.filteredRequests.isEmpty) {
                return const MyRequestsEmptyState();
              }
              return ListView.separated(
                controller: controller.scrollController,
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                itemCount: controller.filteredRequests.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final req = controller.filteredRequests[i];
                  return MyRequestsCard(
                    request: req,
                    onTap: () => controller.viewDetails(req),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.CREATE_REQUEST_TYPE),
        backgroundColor: AppColors.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        icon: Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
        label: Text(
          'New Request',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.searchRequests,
          style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: AppText.searchRequests,
            hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.slate300),
            prefixIcon:
                Icon(Icons.search_rounded, color: AppColors.textSlate, size: 20.sp),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ),
    );
  }
}
