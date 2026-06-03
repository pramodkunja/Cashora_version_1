import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/app_text.dart';
import 'package:cash/utils/mappers/expense_category_visuals.dart';

/// Audit-trail timeline card for the Completed Request Details screen.
///
/// Extracted from `completed_request_details_view.dart` to bring the
/// parent screen file under 400 lines. Renders byte-identical output to
/// the previous inline `_buildAuditTrailCard` implementation — the only
/// change is that the rendering logic now lives in its own widget +
/// private helpers.
class CompletedAuditTrail extends StatelessWidget {
  /// Raw audit-trail entries from the backend. Each entry can be a Map
  /// with any of the well-known label / actor / timestamp keys; missing
  /// keys are tolerated and fall back to sensible defaults.
  final List auditTrail;

  const CompletedAuditTrail({super.key, required this.auditTrail});

  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      icon: Icons.history_rounded,
      title: AppText.auditTrail,
      child: Column(
        children: auditTrail.asMap().entries.map((entry) {
          final index = entry.key;
          final raw = entry.value;
          final isLast = index == auditTrail.length - 1;

          // Be permissive about the backend's key names — different
          // endpoints have shipped slightly different shapes over time.
          final item = raw is Map ? raw : <String, dynamic>{};
          final label = _pick(item, const [
            'label',
            'action',
            'event',
            'event_name',
            'type',
            'status',
          ]);
          var actor = _pick(item, const [
            'actor',
            'actor_name',
            'performed_by',
            'performed_by_name',
            'by',
            'user',
            'user_name',
          ]);
          // If `actor` came back as a nested object, drill in.
          if (actor.isEmpty && item['actor'] is Map) {
            final a = item['actor'] as Map;
            final n = _pick(a, const ['name', 'full_name']);
            actor = n.isNotEmpty
                ? n
                : '${a['first_name'] ?? ''} ${a['last_name'] ?? ''}'.trim();
          }
          final role = _pick(item, const [
            'actor_role',
            'role',
            'user_role',
          ]);
          final noteText = _pick(item, const [
            'note',
            'comment',
            'remark',
            'reason',
            'message',
          ]);
          final timestamp = _pick(item, const [
            'timestamp',
            'at',
            'created_at',
            'performed_at',
            'time',
            'date',
            'updated_at',
          ]);

          if (label.isEmpty) {
            debugPrint(
              '[completed_details] audit row label missing — keys=${item.keys.toList()}',
            );
          }

          return _timelineItem(
            title: label.isEmpty ? 'Update' : label,
            actor: actor,
            role: role,
            note: noteText.isEmpty ? null : noteText,
            date: _formatDateTime(timestamp),
            icon: ExpenseCategoryVisuals.iconFor(label),
            color: _colorFor(label),
            bg: _bgFor(label),
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

  static String _pick(Map item, List<String> keys) {
    for (final k in keys) {
      final v = item[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return '';
  }

  /// Wraps the timeline column in the same section-card chrome used
  /// elsewhere on the screen — purple icon tile + title + body.
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String title,
    required String actor,
    required String role,
    required String? note,
    required String date,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: color.withValues(alpha: 0.15), width: 1),
                ),
                child: Icon(icon, color: color, size: 16.sp),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    color: AppColors.slate100,
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (actor.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      role.isNotEmpty ? '$actor • $role' : actor,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.textSlate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (note != null && note.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        note,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  if (date.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: AppColors.slate300,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('paid')) return AppColors.successGreen;
    if (l.contains('approv')) return AppColors.primary;
    if (l.contains('reject')) return AppColors.errorRed;
    if (l.contains('submit')) return AppColors.textSlate;
    return AppColors.textSlate;
  }

  Color _bgFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('paid')) return AppColors.mintBg;
    if (l.contains('approv')) return AppColors.purpleSurface;
    if (l.contains('reject')) return const Color(0xFFFEF2F2);
    if (l.contains('submit')) return AppColors.backgroundAlt;
    return AppColors.backgroundAlt;
  }

  /// Audit-trail-specific timestamp formatting:
  /// `Jan 15, 2026 · 3:45 PM`.
  /// Distinct from `DateHelper.formatDateTime` (which uses Today / Yesterday
  /// shortcuts) — this view shows the full date for every audit step.
  String _formatDateTime(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final m = dt.minute.toString().padLeft(2, '0');
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$m $amPm';
    } catch (_) {
      return dateStr;
    }
  }
}
