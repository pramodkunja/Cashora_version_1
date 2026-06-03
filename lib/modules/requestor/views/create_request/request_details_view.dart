import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/create_request_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';

class RequestDetailsView extends GetView<CreateRequestController> {
  const RequestDetailsView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Amount Card ──
                  _buildSectionCard(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Amount',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundAlt,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: controller.amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: GoogleFonts.inter(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.slate300,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(
                                  left: 20.w,
                                  right: 8.w,
                                ),
                                child: Text(
                                  '₹',
                                  style: GoogleFonts.inter(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSlate,
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 16.h,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Obx(() {
                          if (controller.amount.value <= 0) {
                            return const SizedBox.shrink();
                          }
                          final needsApproval =
                              controller.category.value == 'Approval Required';
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: needsApproval ? AppColors.amberBg : AppColors.mintBg,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  needsApproval
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_rounded,
                                  color: needsApproval ? AppColors.warningOrange : AppColors.successGreen,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    needsApproval
                                        ? 'Approval required • exceeds limit'
                                        : 'Within limit • auto-approved',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: needsApproval ? AppColors.warningOrange : AppColors.successGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Category Card ──
                  GetBuilder<CreateRequestController>(
                    id: 'category_grid',
                    builder: (_) {
                      final bool isExpanded = controller
                          .expenseCategories
                          .isNotEmpty; // Can add toggle logic later if needed

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select Category',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSlate,
                                size: 24.sp,
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            SizedBox(height: 6.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8.w,
                                    mainAxisSpacing: 8.h,
                                    childAspectRatio: 1.15, // Aspect ratio makes it completely fluid and responsive
                                  ),
                              itemCount: controller.expenseCategories.length,
                              itemBuilder: (context, index) {
                                final cat = controller.expenseCategories[index];
                                final isSelected = controller.selectedExpenseCategory.value != null &&
                                    controller.selectedExpenseCategory.value!['id'] == cat['id'];

                                final borderColors = [
                                  const Color(0xFFEF4444), // Red
                                  const Color(0xFFEF4444),
                                  const Color(0xFF10B981), // Green
                                  const Color(0xFF10B981),
                                  const Color(0xFFEF4444),
                                  const Color(0xFF10B981),
                                  const Color(0xFF10B981),
                                  const Color(0xFFEF4444),
                                  const Color(0xFF10B981),
                                  const Color(0xFF10B981),
                                  const Color(0xFF10B981),
                                  const Color(0xFFEF4444),
                                ];

                                final iconColors = [
                                  const Color(0xFF3B82F6), // Blue
                                  const Color(0xFFEC4899), // Pink
                                  const Color(0xFF3B82F6), // Blue
                                  const Color(0xFFF59E0B), // Orange
                                  const Color(0xFF8B5CF6), // Purple
                                  const Color(0xFF10B981), // Green
                                  const Color(0xFFEF4444), // Red
                                  const Color(0xFF06B6D4), // Cyan
                                  const Color(0xFF3B82F6), // Blue
                                  const Color(0xFF8B5CF6), // Purple
                                  const Color(0xFF10B981), // Green
                                  const Color(0xFFEC4899), // Pink
                                ];

                                final borderColor =
                                    borderColors[index % borderColors.length];
                                final iconColor =
                                    iconColors[index % iconColors.length];
                                final iconBgColor = iconColor.withValues(alpha: 0.1);

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (isSelected) {
                                        controller
                                                .selectedExpenseCategory
                                                .value =
                                            null;
                                      } else {
                                        controller
                                                .selectedExpenseCategory
                                                .value =
                                            cat;
                                      }
                                      controller.update(['category_grid']); // Force foolproof UI rebuild
                                    },
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.purpleSurface
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : borderColor,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10.w),
                                            decoration: BoxDecoration(
                                              color: iconBgColor,
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Icon(
                                              cat['icon'] as IconData,
                                              color: iconColor,
                                              size: 24.sp,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4.w,
                                            ),
                                            child: Text(
                                              cat['name'],
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 10
                                                    .sp, // Slightly smaller text to prevent clipping
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.textDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 14.h),

                  // ── Purpose Card ──
                  _buildSectionCard(
                    icon: Icons.description_rounded,
                    title: AppText.purpose,
                    child: _textField(
                      controller: controller.purposeController,
                      hint: AppText.purposeHint,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Description Card ──
                  _buildSectionCard(
                    icon: Icons.notes_rounded,
                    title: AppText.descriptionOptional,
                    child: _textField(
                      controller: controller.descriptionController,
                      hint: AppText.descriptionPlaceholder,
                      maxLines: 4,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Payment Note Card ──
                  _buildSectionCard(
                    icon: Icons.edit_note_rounded,
                    title: 'Payment Note (Optional)',
                    child: _textField(
                      controller: controller.paymentNoteController,
                      hint: 'e.g. Pay to UPI: yourname@upi',
                      maxLines: 2,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Attachments Card ──
                  _buildSectionCard(
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
                                _uploadChip(
                                  icon: Icons.qr_code_scanner_rounded,
                                  label: 'Upload QR',
                                  onTap: () => _showAttachmentOptions(
                                    Get.context!,
                                    isQr: true,
                                  ),
                                ),
                              if (controller.requestType.value ==
                                      'Post-approved' &&
                                  controller.receiptFile.value == null)
                                _uploadChip(
                                  icon: Icons.receipt_long_rounded,
                                  label: 'Upload Receipt',
                                  onTap: () => _showAttachmentOptions(
                                    Get.context!,
                                    isQr: false,
                                    isReceipt: true,
                                  ),
                                ),
                              _uploadChip(
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
                            _fileItem(
                              'QR Code',
                              Icons.qr_code_2_rounded,
                              () => controller.removeQr(),
                            ),
                          if (controller.requestType.value == 'Post-approved' &&
                              controller.receiptFile.value != null)
                            _fileItem(
                              'Receipt Uploaded',
                              Icons.receipt_long_rounded,
                              () => controller.removeReceipt(),
                            ),
                          if (controller.requestType.value == 'Pre-approved')
                            ...controller.attachedFiles.asMap().entries.map((
                              entry,
                            ) {
                              return _fileItem(
                                entry.value.name,
                                Icons.description_rounded,
                                () => controller.removeFile(entry.key),
                              );
                            }),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        22.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            AppText.requestDetails,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ───────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: () {
              if (controller.validateRequest()) {
                Get.toNamed(AppRoutes.CREATE_REQUEST_REVIEW);
              }
            },
            icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
            label: Text(
              AppText.reviewRequest,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Reusable: Section Card ──
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.slate300),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _uploadChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: AppColors.purpleSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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

  Widget _fileItem(String name, IconData icon, VoidCallback onRemove) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.mintBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
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
            _bottomSheetOption(
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
            _bottomSheetOption(
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

  Widget _bottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
            Icon(Icons.chevron_right_rounded, color: AppColors.slate300, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
