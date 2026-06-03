import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cash/utils/app_colors.dart';

/// Attachments card for the Completed Request Details screen.
///
/// Renders up to two image tiles (receipt + payment QR), each opening
/// a full-screen InteractiveViewer dialog on tap. Extracted from the
/// parent view file to keep the screen under the 400-line target.
///
/// Empty URLs are skipped — if both are empty the card body is empty
/// (parent typically guards by not rendering this widget at all).
class CompletedAttachmentsCard extends StatelessWidget {
  final String receiptUrl;
  final String paymentQrUrl;

  const CompletedAttachmentsCard({
    super.key,
    required this.receiptUrl,
    required this.paymentQrUrl,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    if (receiptUrl.isNotEmpty) {
      tiles.add(_attachmentTile(
        label: 'Receipt',
        url: receiptUrl,
        icon: Icons.receipt_long_rounded,
      ));
    }
    if (paymentQrUrl.isNotEmpty) {
      if (tiles.isNotEmpty) tiles.add(SizedBox(width: 12.w));
      tiles.add(_attachmentTile(
        label: 'Payment QR',
        url: paymentQrUrl,
        icon: Icons.qr_code_2_rounded,
      ));
    }
    return _sectionCard(
      icon: Icons.attach_file_rounded,
      title: 'Attachments',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tiles.map((t) => Expanded(child: t)).toList(),
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

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

  Widget _attachmentTile({
    required String label,
    required String url,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => _openImagePreview(url, label),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.slate100, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: AppColors.slate100,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.slate100,
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.slate300,
                      size: 28.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(icon, size: 14.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Icon(Icons.open_in_full_rounded,
                    size: 12.sp, color: AppColors.textSlate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openImagePreview(String url, String title) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(12.w),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  url,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 48.sp,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white, size: 18.sp),
                ),
              ),
            ),
            Positioned(
              top: 14.h,
              left: 14.w,
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
