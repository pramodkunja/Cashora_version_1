import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'skeleton_loader.dart';

/// A single transaction-row shimmer placeholder used by both the
/// accountant dashboard and the financial reports preview skeletons.
class PageSkeletonTxnRow extends StatelessWidget {
  const PageSkeletonTxnRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SkeletonBlock(width: 38.w, height: 38.w, radius: 10.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 140.w, height: 12.h, radius: 4.r),
                SizedBox(height: 8.h),
                SkeletonBlock(width: 80.w, height: 10.h, radius: 4.r),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          SkeletonBlock(width: 72.w, height: 14.h, radius: 4.r),
        ],
      ),
    );
  }
}
