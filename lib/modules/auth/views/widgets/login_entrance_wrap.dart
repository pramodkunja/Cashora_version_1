import 'package:flutter/material.dart';

/// Shared entrance animation wrapper used across the login screen.
/// Fades + slides the child upward when first built.
class LoginEntranceWrap extends StatelessWidget {
  const LoginEntranceWrap({
    super.key,
    required this.child,
    required this.duration,
  });

  final Widget child;
  final Duration duration;

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
            offset: Offset(0, 20 * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
