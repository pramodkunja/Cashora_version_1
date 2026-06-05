import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'skeleton_loader.dart';

/// Profile skeleton: mirrors the loaded profile layout exactly — purple
/// gradient header (back / title / edit + avatar + name + role+email row),
/// then info card with rows, admin/settings cards, then logout button.
///
/// Using the same gradient header in the same spot means the transition
/// from loading → loaded is a clean shimmer-to-content swap with no
/// vertical shift.
class ProfilePageSkeleton extends StatelessWidget {
  const ProfilePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _Header(),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(width: 110.w),
              SizedBox(height: 10.h),
              _RowsCard(rowCount: 5),
              SizedBox(height: 20.h),
              _label(width: 70.w),
              SizedBox(height: 10.h),
              _RowsCard(rowCount: 3, withChevron: true),
              SizedBox(height: 20.h),
              _label(width: 90.w),
              SizedBox(height: 10.h),
              _RowsCard(rowCount: 2, withChevron: true),
              SizedBox(height: 28.h),
              _LogoutPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label({required double width}) =>
      SkeletonBlock(width: width, height: 11.h, radius: 4.r);
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final paint = Colors.white.withValues(alpha: 0.18);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24.w,
        MediaQuery.of(context).padding.top + 12.h,
        24.w,
        32.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          // Top row — back / title / edit placeholders
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: paint,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              Container(
                width: 110.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: paint,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              const Spacer(),
              Container(
                width: 56.w,
                height: 26.h,
                decoration: BoxDecoration(
                  color: paint,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Avatar ring + filled disc
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2.5.w),
            ),
            child: Container(
              width: 84.w,
              height: 84.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          // Name placeholder
          Container(
            width: 180.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: paint,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          SizedBox(height: 8.h),
          // Role badge + email row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: paint,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 130.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: paint,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A card with [rowCount] info/action-style rows: icon bubble on the left,
/// title line, optional secondary line, optional trailing chevron pill.
class _RowsCard extends StatelessWidget {
  final int rowCount;
  final bool withChevron;
  const _RowsCard({required this.rowCount, this.withChevron = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      child: Column(
        children: List.generate(rowCount, (i) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Row(
                  children: [
                    SkeletonBlock(width: 34.w, height: 34.w, radius: 10.r),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SkeletonBlock(width: 90.w, height: 10.h, radius: 4.r),
                          SizedBox(height: 8.h),
                          SkeletonBlock(
                            width: 140.w + (i.isEven ? 30.w : 0),
                            height: 12.h,
                            radius: 4.r,
                          ),
                        ],
                      ),
                    ),
                    if (withChevron) ...[
                      SizedBox(width: 10.w),
                      SkeletonBlock(width: 14.w, height: 14.w, radius: 7.r),
                    ],
                  ],
                ),
              ),
              if (i < rowCount - 1)
                Container(height: 1, color: const Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }
}

class _LogoutPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Center(
        child: SkeletonBlock(width: 90.w, height: 14.h, radius: 4.r),
      ),
    );
  }
}
