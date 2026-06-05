import 'package:flutter/material.dart';

/// Status variants supported by `RequestDetailsLayout`. Drives the
/// gradient header colour, status pill text, and which optional
/// sections render (rejection reason, approval timeline).
enum RequestDetailVariant {
  pending,
  approved,
  rejected,

  /// Accountant view — the expense was already approved and is now
  /// awaiting payment. Uses the approved palette but suppresses the
  /// timeline since the bottom actions handle the workflow.
  awaitingPayment,
}

/// Resolved visual style for a request detail screen variant — gradient
/// colours, status pill icon, and status pill text.
class RequestVariantStyle {
  final Color gradientStart;
  final Color gradientEnd;
  final IconData statusIcon;
  final String statusLabel;

  const RequestVariantStyle({
    required this.gradientStart,
    required this.gradientEnd,
    required this.statusIcon,
    required this.statusLabel,
  });

  static RequestVariantStyle forVariant(RequestDetailVariant v) {
    switch (v) {
      case RequestDetailVariant.approved:
      case RequestDetailVariant.awaitingPayment:
        return const RequestVariantStyle(
          gradientStart: Color(0xFF10B981),
          gradientEnd: Color(0xFF047857),
          statusIcon: Icons.check_circle_rounded,
          statusLabel: 'APPROVED',
        );
      case RequestDetailVariant.rejected:
        return const RequestVariantStyle(
          gradientStart: Color(0xFFE25C5C),
          gradientEnd: Color(0xFFB91C1C),
          statusIcon: Icons.block_rounded,
          statusLabel: 'REJECTED',
        );
      case RequestDetailVariant.pending:
        return const RequestVariantStyle(
          gradientStart: Color(0xFF7C68D4),
          gradientEnd: Color(0xFF5B45B0),
          statusIcon: Icons.hourglass_top_rounded,
          statusLabel: 'PENDING',
        );
    }
  }
}
