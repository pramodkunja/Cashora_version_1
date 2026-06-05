import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'page_skeleton_txn_row.dart';
import 'skeleton_loader.dart';

/// Accountant dashboard skeleton: hero account-overview card + two stat
/// tiles + a transactions list placeholder.
///
/// Renders as a non-scrolling Column so it can be embedded inside the
/// dashboard's existing CustomScrollView/SliverList without nesting
/// scrollables.
class AccountantDashboardSkeleton extends StatelessWidget {
  const AccountantDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero balance card.
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(width: 120.w, height: 12.h, radius: 4.r),
                SizedBox(height: 14.h),
                SkeletonBlock(width: 200.w, height: 30.h, radius: 6.r),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(child: SkeletonBlock(height: 38.h, radius: 8.r)),
                    SizedBox(width: 14.w),
                    Expanded(child: SkeletonBlock(height: 38.h, radius: 8.r)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Two stat cards.
          Row(
            children: [
              Expanded(child: SkeletonCard(height: 70.h)),
              SizedBox(width: 12.w),
              Expanded(child: SkeletonCard(height: 70.h)),
            ],
          ),
          SizedBox(height: 24.h),

          // Section title.
          SkeletonBlock(width: 160.w, height: 16.h, radius: 4.r),
          SizedBox(height: 14.h),

          // Transactions list.
          for (int i = 0; i < 4; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: const PageSkeletonTxnRow(),
            ),
        ],
      ),
    );
  }
}
