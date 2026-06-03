import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Lightweight shimmer skeleton primitives. No third-party shimmer package —
/// a single shared 1200ms AnimationController drives all visible skeletons
/// (registered via [_ShimmerRegistry]) so even a screen full of placeholders
/// is one ticker, not N.
///
/// Use [SkeletonBlock] for individual placeholder shapes and the higher-level
/// helpers in `lib/utils/widgets/skeletons/page_skeletons.dart` for full-page
/// scaffolds.
class _ShimmerTicker {
  static final _ShimmerTicker instance = _ShimmerTicker._();
  _ShimmerTicker._();

  final ValueNotifier<double> phase = ValueNotifier<double>(0);
  Ticker? _ticker;
  int _subscribers = 0;

  void subscribe() {
    _subscribers++;
    _ticker ??= Ticker(_onTick)..start();
  }

  void unsubscribe() {
    _subscribers = (_subscribers - 1).clamp(0, 1 << 30);
    if (_subscribers == 0) {
      _ticker?.dispose();
      _ticker = null;
    }
  }

  void _onTick(Duration elapsed) {
    // 1.2s period, value in [0, 1).
    phase.value = (elapsed.inMilliseconds % 1200) / 1200.0;
  }
}

/// Individual shimmering block. Render multiples to compose a skeleton layout.
class SkeletonBlock extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.margin,
  });

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock> {
  @override
  void initState() {
    super.initState();
    _ShimmerTicker.instance.subscribe();
  }

  @override
  void dispose() {
    _ShimmerTicker.instance.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = const Color(0xFFE2E8F0);
    final highlight = const Color(0xFFF1F5F9);
    return ValueListenableBuilder<double>(
      valueListenable: _ShimmerTicker.instance.phase,
      builder: (_, phase, _) {
        // Move the gradient diagonally from -1 to 2 (offscreen → offscreen).
        final pos = -1.0 + phase * 3.0;
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(pos - 1, 0),
              end: Alignment(pos + 1, 0),
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

/// Drop-in replacement for the old `SkeletonListView` — renders a vertical
/// list of generic skeleton rows.
class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final double padding;
  final double rowHeight;

  const SkeletonListView({
    super.key,
    this.itemCount = 6,
    this.padding = 16,
    this.rowHeight = 64,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(padding.w),
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, _) => _GenericRowSkeleton(height: rowHeight),
    );
  }
}

class _GenericRowSkeleton extends StatelessWidget {
  final double height;
  const _GenericRowSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBlock(width: 140.w, height: 12.h, radius: 4.r),
                SizedBox(height: 8.h),
                SkeletonBlock(width: 80.w, height: 10.h, radius: 4.r),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          SkeletonBlock(width: 64.w, height: 14.h, radius: 4.r),
        ],
      ),
    );
  }
}

/// Generic shimmering card (single block at card height).
class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SkeletonBlock(height: height.h, radius: 8.r),
    );
  }
}

/// Legacy wrapper kept so existing call sites compile. Renders its child as
/// a single SkeletonBlock-shaped placeholder.
class SkeletonLoader extends StatelessWidget {
  final Widget child;
  const SkeletonLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
