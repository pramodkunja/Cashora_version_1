import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text.dart';
import '../../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../../controllers/create_request_controller.dart';
import 'review_request_section_card.dart';

/// Attachments section card — shows QR / receipt / extra files attached to
/// the request, or an empty-state hint if none are selected.
class ReviewRequestAttachments extends StatelessWidget {
  final CreateRequestController controller;
  const ReviewRequestAttachments({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ReviewRequestSectionCard(
      icon: Icons.attach_file_rounded,
      title: AppText.attachments,
      children: [
        Obx(() {
          final allFiles = <XFile>[];
          if (controller.qrFile.value != null) {
            allFiles.add(controller.qrFile.value!);
          }
          if (controller.receiptFile.value != null) {
            allFiles.add(controller.receiptFile.value!);
          }
          allFiles.addAll(controller.attachedFiles);

          if (allFiles.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                AppText.noAttachments,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textSlate,
                ),
              ),
            );
          }

          return Column(
            children: allFiles.map((file) {
              final isQr = file == controller.qrFile.value;
              final isReceipt = file == controller.receiptFile.value;
              String label = file.name;
              IconData icon = Icons.image_rounded;
              if (isQr) {
                label = 'QR Code';
                icon = Icons.qr_code_2_rounded;
              } else if (isReceipt) {
                label = 'Receipt';
                icon = Icons.receipt_long_rounded;
              }
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GestureDetector(
                  onTap: () => _showImagePreview(Get.context!, file),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(12.r),
                      border:
                          Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.purpleSurface,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(icon,
                              color: AppColors.primary, size: 18.sp),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isQr || isReceipt)
                                Text(
                                  file.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    color: AppColors.textSlate,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Icon(Icons.visibility_rounded,
                            color: AppColors.textSlate, size: 16.sp),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  void _showImagePreview(BuildContext context, XFile file) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.white,
              ),
              clipBehavior: Clip.hardEdge,
              child: FutureBuilder<Uint8List>(
                future: file.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SkeletonBlock(height: 200.h, radius: 12.r);
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 200.h,
                      child:
                          const Center(child: Text('Error loading preview')),
                    );
                  }
                  if (snapshot.hasData) {
                    return Image.memory(snapshot.data!, fit: BoxFit.contain);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white, size: 20.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
