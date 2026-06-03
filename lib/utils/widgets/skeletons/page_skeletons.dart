import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              child: _TxnRowSkeleton(),
            ),
        ],
      ),
    );
  }
}

class _TxnRowSkeleton extends StatelessWidget {
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
                  child: _TxnRowSkeleton(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
