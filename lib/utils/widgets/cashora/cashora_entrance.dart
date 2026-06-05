import 'package:flutter/material.dart';

/// One-shot slide-up + fade-in animation that runs the first (and only)
/// time the widget mounts. Stateless — no controller needed.
///
/// Stagger sibling children by passing **longer** durations to later
/// items (a 1100ms wrap visibly settles after a 700ms one).
class EntranceWrap extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const EntranceWrap({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.offset = 20,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, t, c) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
