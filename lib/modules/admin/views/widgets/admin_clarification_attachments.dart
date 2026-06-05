import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/attachment_card.dart';

/// Attachments card for the Admin Clarification Status screen.
///
/// Collects attachments from multiple possible request-map shapes
/// (`attachments[]`, `receipt_url`, `payment_qr_url`, `bill_urls[]`),
/// dedupes by URL, and renders them as a vertical list of
/// `AttachmentCard`s. Extracted from
/// `admin_clarification_status_view.dart`.
class AdminClarificationAttachments extends StatelessWidget {
  final Map<dynamic, dynamic> request;

  const AdminClarificationAttachments({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final items = _collectAttachments(request);
    if (items.isEmpty) {
      return _whiteCard(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Center(
          child: Text(
            'No attachments',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSlate,
            ),
          ),
        ),
      );
    }
    return _whiteCard(
      padding: EdgeInsets.all(12.w),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (_, i) => AttachmentCard(attachment: items[i], index: i),
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

  List<Map<String, dynamic>> _collectAttachments(Map<dynamic, dynamic> req) {
    final out = <Map<String, dynamic>>[];
    final seen = <String>{};
    void add(String name, dynamic url) {
      if (url == null) return;
      final s = url.toString();
      if (s.isEmpty || !seen.add(s)) return;
      out.add({'name': name, 'url': s, 'file': s});
    }

    if (req['attachments'] is List) {
      for (final raw in (req['attachments'] as List)) {
        if (raw is Map) {
          final url = raw['url'] ?? raw['file'];
          add(raw['name']?.toString() ?? 'Attachment', url);
        }
      }
    }
    add('Receipt', req['receipt_url']);
    add('QR Code', req['payment_qr_url'] ?? req['qr_url']);
    if (req['bill_urls'] is List) {
      final bills = req['bill_urls'] as List;
      for (int i = 0; i < bills.length; i++) {
        add(bills.length > 1 ? 'Bill ${i + 1}' : 'Bill', bills[i]);
      }
    }
    return out;
  }

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(18.w),
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
      child: child,
    );
  }
}
