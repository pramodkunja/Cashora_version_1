import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final Widget child;
  const SkeletonLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Determine shimmer colors based on theme brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? (Colors.grey[800] ?? Colors.grey.shade800) : (Colors.grey[300] ?? Colors.grey.shade300);
    final highlightColor = isDark ? (Colors.grey[700] ?? Colors.grey.shade700) : (Colors.grey[100] ?? Colors.grey.shade100);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

class SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // Color is overridden by Shimmer parent
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final double padding;

  const SkeletonListView({super.key, this.itemCount = 6, this.padding = 24});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: padding.w, vertical: 16.h),
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                SkeletonBlock(
                  width: 56.w,
                  height: 56.w,
                  radius: 28.r,
                ), // Avatar
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBlock(width: 150.w, height: 16.h), // Name
                      SizedBox(height: 8.h),
                      SkeletonBlock(width: 100.w, height: 12.h), // Subtitle
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                SkeletonBlock(width: 16.w, height: 16.w, radius: 4), // Icon
              ],
            ),
          );
        },
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBlock(width: 120.w, height: 20.h),
                SkeletonBlock(width: 60.w, height: 20.h),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: SkeletonBlock(width: double.infinity, height: 40.h),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
