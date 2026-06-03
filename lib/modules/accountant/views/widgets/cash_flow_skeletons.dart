import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/widgets/skeletons/skeleton_loader.dart';

/// First-paint skeletons for the "Today's Transactions" screen.
///
/// Mirror the real hero card + list layout so the page feels instant.
/// No empty ₹0 values, no jump when data arrives. Extracted from
/// `cash_flow_history_view.dart` to keep the parent under 400 lines.

class CashFlowHeroSkeleton extends StatelessWidget {
  const CashFlowHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B45B0).withValues(alpha: 0.10),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 16.h),
            child: Row(
              children: [
                const Expanded(child: _StatTileSkeleton()),
                Container(width: 1, height: 60.h, color: AppColors.slate100),
                const Expanded(child: _StatTileSkeleton()),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(22.r),
              ),
            ),
            child: Row(
              children: [
                SkeletonBlock(width: 36.w, height: 36.w, radius: 18.r),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonBlock(width: 70.w, height: 10.h, radius: 3.r),
                    SizedBox(height: 6.h),
                    SkeletonBlock(width: 120.w, height: 18.h, radius: 4.r),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTileSkeleton extends StatelessWidget {
  const _StatTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonBlock(width: 34.w, height: 34.w, radius: 10.r),
          SizedBox(height: 12.h),
          SkeletonBlock(width: 56.w, height: 10.h, radius: 3.r),
          SizedBox(height: 6.h),
          SkeletonBlock(width: 90.w, height: 22.h, radius: 4.r),
        ],
      ),
    );
  }
}

class CashFlowBodySkeleton extends StatelessWidget {
  const CashFlowBodySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(width: 130.w, height: 11.h, radius: 3.r),
        SizedBox(height: 12.h),
        ...List.generate(
          5,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SkeletonBlock(width: 44.w, height: 44.w, radius: 12.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkeletonBlock(
                            width: 140.w, height: 12.h, radius: 4.r),
                        SizedBox(height: 6.h),
                        SkeletonBlock(
                            width: 90.w, height: 10.h, radius: 4.r),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkeletonBlock(width: 60.w, height: 14.h, radius: 4.r),
                      SizedBox(height: 6.h),
                      SkeletonBlock(width: 40.w, height: 10.h, radius: 4.r),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
