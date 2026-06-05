import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'page_skeleton_txn_row.dart';
import 'skeleton_loader.dart';

/// Financial-reports preview skeleton: hero total card + categories card +
/// transactions list.
class ReportsPreviewSkeleton extends StatelessWidget {
  const ReportsPreviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero total card.
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(22.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBlock(width: 32.w, height: 32.w, radius: 10.r),
                  SizedBox(width: 10.w),
                  SkeletonBlock(width: 120.w, height: 12.h, radius: 4.r),
                  const Spacer(),
                  SkeletonBlock(width: 70.w, height: 22.h, radius: 12.r),
                ],
              ),
              SizedBox(height: 14.h),
              SkeletonBlock(width: 220.w, height: 36.h, radius: 6.r),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(child: SkeletonBlock(height: 32.h, radius: 4.r)),
                  SizedBox(width: 16.w),
                  Expanded(child: SkeletonBlock(height: 32.h, radius: 4.r)),
                  SizedBox(width: 16.w),
                  Expanded(child: SkeletonBlock(height: 32.h, radius: 4.r)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Top categories card.
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == 2 ? 0 : 14.h),
                  child: Column(
                    children: [
                      Row(
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
                      SizedBox(height: 8.h),
                      SkeletonBlock(height: 6.h, radius: 3.r),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Transactions card.
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == 2 ? 0 : 10.h),
                  child: const PageSkeletonTxnRow(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
