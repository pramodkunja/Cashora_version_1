import 'package:flutter/material.dart';
import '../app_loader.dart';

/// Legacy skeleton wrappers — shimmer skeleton loading has been replaced by
/// the line-sweep `AppLoader`. The classes remain so existing call sites keep
/// compiling; they just render the new loader instead.

class SkeletonLoader extends StatelessWidget {
  final Widget child;
  const SkeletonLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) => const AppLoader();
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
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final double padding;

  const SkeletonListView({super.key, this.itemCount = 6, this.padding = 24});

  @override
  Widget build(BuildContext context) => const AppLoader();
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) => const AppLoader();
}
