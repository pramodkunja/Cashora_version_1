import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import '../../../controllers/create_request_controller.dart';
import 'create_request_primitives.dart';

/// Attachments section card — upload chips for QR / Receipt / Bill, plus
/// rows for each uploaded file. Tapping a chip opens a camera/gallery
/// bottom sheet via [_showAttachmentOptions].
class CreateRequestAttachments extends StatelessWidget {
  final CreateRequestController controller;
  const CreateRequestAttachments({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CreateRequestSectionCard(
      icon: Icons.attach_file_rounded,
      title: 'Attachments',
      child: Obx(() {
        if (controller.requestType.value.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              'Please select a request type first',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textSlate,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (controller.qrFile.value == null)
                  _UploadChip(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Upload QR',
                    onTap: () => _showAttachmentOptions(
                      Get.context!,
                      isQr: true,
                    ),
                  ),
                if (controller.requestType.value == 'Post-approved' &&
                    controller.receiptFile.value == null)
                  _UploadChip(
                    icon: Icons.receipt_long_rounded,
                    label: 'Upload Receipt',
                    onTap: () => _showAttachmentOptions(
                      Get.context!,
                      isQr: false,
                      isReceipt: true,
                    ),
                  ),
                _UploadChip(
                  icon: Icons.upload_file_rounded,
                  label: AppText.uploadBill,
                  onTap: () => _showAttachmentOptions(
                    Get.context!,
                    isQr: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (controller.qrFile.value != null)
              _FileItem(
                name: 'QR Code',
                icon: Icons.qr_code_2_rounded,
                onRemove: controller.removeQr,
              ),
            if (controller.requestType.value == 'Post-approved' &&
                controller.receiptFile.value != null)
              _FileItem(
                name: 'Receipt Uploaded',
                icon: Icons.receipt_long_rounded,
                onRemove: controller.removeReceipt,
              ),
            if (controller.requestType.value == 'Pre-approved')
              ...controller.attachedFiles.asMap().entries.map(
                    (entry) => _FileItem(
                      name: entry.value.name,
                      icon: Icons.description_rounded,
                      onRemove: () => controller.removeFile(entry.key),
                    ),
                  ),
          ],
        );
      }),
    );
  }

  void _showAttachmentOptions(
    BuildContext context, {
    required bool isQr,
    bool isReceipt = false,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Select Option',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 20.h),
            _SheetOption(
              icon: Icons.camera_alt_rounded,
              label: 'Capture Image',
              onTap: () {
                Get.back();
                controller.pickImage(
                  ImageSource.camera,
                  isQr: isQr,
                  isReceipt: isReceipt,
                );
              },
            ),
            SizedBox(height: 10.h),
            _SheetOption(
              icon: Icons.photo_library_rounded,
              label: 'Upload from Gallery',
              onTap: () {
                Get.back();
                controller.pickImage(
                  ImageSource.gallery,
                  isQr: isQr,
                  isReceipt: isReceipt,
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _UploadChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: AppColors.purpleSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onRemove;

  const _FileItem({
    required this.name,
    required this.icon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.mintBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.successGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.successGreen, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              color: AppColors.errorRed,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.purpleSurface,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.slate300,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
