import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';

/// Bills & attachments card for the Admin Request Details screen.
///
/// Extracted from `admin_request_details_view.dart` to bring the
/// parent screen file under the 400-line target. Renders byte-identical
/// output to the previous inline implementation.
///
/// Pure presentation: takes the request map + a tap callback so the
/// widget has no controller dependency.
class AdminAttachmentsSection extends StatelessWidget {
  final Map<dynamic, dynamic> request;
  final void Function(String url) onAttachmentTap;

  const AdminAttachmentsSection({
    super.key,
    required this.request,
    required this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: AppColors.textDark,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Bill & Attachments",
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = (constraints.maxWidth - 16.w) / 2;
              return Wrap(
                spacing: 16.w,
                runSpacing: 16.w,
                children: _buildAttachmentButtons(context, itemWidth),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

  List<Widget> _buildAttachmentButtons(BuildContext context, double width) {
    final buttons = <Widget>[];

    // Dedupe by URL so the receipt/qr aren't shown twice when both the raw
    // url keys (`receipt_url`, `payment_qr_url`) and the pre-built
    // `attachments` list contain the same image.
    final Set<String> seen = <String>{};
    void addButton({
      required IconData icon,
      required String label,
      required String? url,
    }) {
      if (url == null || url.isEmpty || !seen.add(url)) return;
      buttons.add(
        _attachmentOption(
          context: context,
          icon: icon,
          label: label,
          onTap: () => onAttachmentTap(url),
          width: width,
        ),
      );
    }

    // Bills can come as `bill_urls[]`, `bill_url`, or the pre-built
    // `attachments[]` list (when the requestor controller already mapped it).
    List<String> billUrls = [];
    if (request['bill_urls'] != null && request['bill_urls'] is List) {
      billUrls = List<String>.from(request['bill_urls']);
    } else if (request['bill_url'] != null) {
      billUrls.add(request['bill_url']);
    } else if (request['attachments'] is List) {
      for (final raw in (request['attachments'] as List)) {
        if (raw is Map) {
          final v = (raw['file_url'] ?? raw['url'] ?? raw['file'])?.toString();
          if (v != null && v.isNotEmpty) billUrls.add(v);
        } else if (raw is String) {
          billUrls.add(raw);
        }
      }
    }

    final receiptUrl = request['receipt_url']?.toString();
    final qrUrl = (request['payment_qr_url'] ??
            request['qr_url'] ??
            request['qr_code_url'])
        ?.toString();

    // 1) Receipt/QR first so they "win" the dedupe over a same-URL bill entry
    //    that was synthesized from the attachments list.
    addButton(
      icon: Icons.check_circle_outline_rounded,
      label: 'View Receipt',
      url: receiptUrl,
    );
    addButton(icon: Icons.qr_code_2_rounded, label: 'View QR', url: qrUrl);

    // 2) Bills (any that survived the dedupe).
    for (int i = 0; i < billUrls.length; i++) {
      addButton(
        icon: Icons.receipt_long_rounded,
        label: billUrls.length > 1 ? 'View Bill ${i + 1}' : 'View Bill',
        url: billUrls[i],
      );
    }

    if (buttons.isEmpty) {
      return [
        Text(
          "No attachments available.",
          style: TextStyle(color: AppColors.textSlate, fontSize: 13.sp),
        ),
      ];
    }

    return buttons;
  }

  Widget _attachmentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16.r),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0284C7),
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: AppTextStyles.h3.copyWith(
                fontSize: 14.sp,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
