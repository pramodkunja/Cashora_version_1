import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'skeleton_loader.dart';

/// Spend analytics page skeleton: filter row + two score cards + chart card
/// + top-categories list.
class SpendAnalyticsSkeleton extends StatelessWidget {
  const SpendAnalyticsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "FILTERS" caps label placeholder — matches the live view.
          SkeletonBlock(width: 60.w, height: 11.h, radius: 3.r),
          SizedBox(height: 10.h),
          // Horizontal scroll mirrors the live filter row so the three
          // chip placeholders don't overflow on narrow phones.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SkeletonBlock(width: 130.w, height: 42.h, radius: 100.r),
                SizedBox(width: 10.w),
                SkeletonBlock(width: 130.w, height: 42.h, radius: 100.r),
                SizedBox(width: 10.w),
                SkeletonBlock(width: 130.w, height: 42.h, radius: 100.r),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: SkeletonCard(height: 90.h)),
              SizedBox(width: 12.w),
              Expanded(child: SkeletonCard(height: 90.h)),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 140.w, height: 14.h, radius: 4.r),
                SizedBox(height: 16.h),
                SkeletonBlock(height: 160.h, radius: 8.r),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                for (int i = 0; i < 4; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == 3 ? 0 : 14.h),
                    child: Row(
                      children: [
                        SkeletonBlock(width: 10.w, height: 10.w, radius: 5.r),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: SkeletonBlock(height: 12.h, radius: 4.r),
                        ),
                        SizedBox(width: 10.w),
                        SkeletonBlock(width: 60.w, height: 12.h, radius: 4.r),
                      ],
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
