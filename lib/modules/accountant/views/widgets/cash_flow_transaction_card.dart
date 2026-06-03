import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';

/// Single transaction row used in the "Today's Transactions" list.
///
/// Extracted from `cash_flow_history_view.dart` to keep the parent under
/// the 400-line target. Pure presentation — the parent supplies the row
/// map and a tap callback so the widget has no controller dependency.
class CashFlowTransactionCard extends StatelessWidget {
  final Map<String, dynamic> tx;
  final VoidCallback onTap;

  const CashFlowTransactionCard({
    super.key,
    required this.tx,
    required this.onTap,
  });

  // ── Palette ──────────────────────────────────────────────────────────
  static const _blue = Color(0xFF0EA5E9);
  static const _blueBg = Color(0xFFE0F2FE);
  static const _pink = Color(0xFFEC4899);
  static const _pinkBg = Color(0xFFFCE7F3);

  @override
  Widget build(BuildContext context) {
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final isOutflow = amount < 0;

    final title = (tx['title'] ?? tx['category'] ?? 'Expense').toString();
    final requestId = (tx['request_id'] ?? '').toString();
    final vendor = (tx['vendor_name'] ?? '').toString();
    final department = (tx['department'] ?? '').toString();
    final requestor = (tx['requestor_name'] ?? '').toString();
    final status = (tx['status'] ?? '').toString().toLowerCase();
    final timestamp = tx['timestamp']?.toString() ?? '';
    final iconType = (tx['icon_type'] ?? '').toString().toLowerCase();

    // Build the subtitle line with the most useful 2-3 bits available.
    final subtitleParts = <String>[];
    if (vendor.isNotEmpty) subtitleParts.add(vendor);
    if (requestor.isNotEmpty) subtitleParts.add(requestor);
    if (department.isNotEmpty && subtitleParts.length < 2) {
      subtitleParts.add(department);
    }
    final subtitle = subtitleParts.join(' · ');

    final iconColor = _iconColorForType(iconType);
    final iconBg = _iconBgForType(iconType);
    final iconData = _iconForType(iconType);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(iconData, color: iconColor, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            if (requestId.isNotEmpty) ...[
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: AppColors.slate100,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  requestId,
                                  style: GoogleFonts.inter(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSlate,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (subtitle.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: AppColors.textSlate,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isOutflow ? '-' : '+'}₹${CurrencyFormatter.inr(amount.abs())}',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: isOutflow
                              ? AppColors.errorRed
                              : AppColors.successGreen,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _formatTime(timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (status.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Divider(height: 1.h, color: AppColors.slate100),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _statusPill(status),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.slate300, size: 20.sp),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

  Widget _statusPill(String status) {
    Color color;
    Color bg;
    String label;
    IconData icon;
    switch (status) {
      case 'paid':
        color = AppColors.successGreen;
        bg = AppColors.mintBg;
        label = 'PAID';
        icon = Icons.check_circle_rounded;
        break;
      case 'approved':
      case 'auto_approved':
        color = AppColors.successGreen;
        bg = AppColors.mintBg;
        label = 'APPROVED';
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        color = AppColors.errorRed;
        bg = AppColors.redBg;
        label = 'REJECTED';
        icon = Icons.cancel_rounded;
        break;
      case 'pending':
        color = AppColors.warningOrange;
        bg = AppColors.amberBg;
        label = 'PENDING';
        icon = Icons.hourglass_top_rounded;
        break;
      default:
        color = AppColors.textSlate;
        bg = AppColors.slate100;
        label = status.toUpperCase();
        icon = Icons.info_outline_rounded;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final hr12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final ampm = h >= 12 ? 'PM' : 'AM';
    return '$hr12:$m $ampm';
  }

  IconData _iconForType(String type) {
    if (type.contains('office') || type.contains('supplies')) {
      return Icons.shopping_bag_rounded;
    }
    if (type.contains('travel') || type.contains('flight')) {
      return Icons.flight_rounded;
    }
    if (type.contains('meal') || type.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (type.contains('software')) return Icons.code_rounded;
    if (type.contains('hardware')) return Icons.devices_other_rounded;
    if (type.contains('transport') || type.contains('taxi')) {
      return Icons.directions_car_rounded;
    }
    return Icons.receipt_long_rounded;
  }

  Color _iconColorForType(String type) {
    if (type.contains('office') || type.contains('supplies')) return _pink;
    if (type.contains('travel') || type.contains('flight')) return _blue;
    if (type.contains('meal') || type.contains('food')) {
      return AppColors.warningOrange;
    }
    if (type.contains('software')) return AppColors.primary;
    if (type.contains('hardware')) return AppColors.primary;
    if (type.contains('transport') || type.contains('taxi')) {
      return AppColors.successGreen;
    }
    return AppColors.primary;
  }

  Color _iconBgForType(String type) {
    if (type.contains('office') || type.contains('supplies')) return _pinkBg;
    if (type.contains('travel') || type.contains('flight')) return _blueBg;
    if (type.contains('meal') || type.contains('food')) {
      return AppColors.amberBg;
    }
    if (type.contains('software')) return AppColors.purpleSurface;
    if (type.contains('hardware')) return AppColors.purpleSurface;
    if (type.contains('transport') || type.contains('taxi')) {
      return AppColors.mintBg;
    }
    return AppColors.purpleSurface;
  }
}
