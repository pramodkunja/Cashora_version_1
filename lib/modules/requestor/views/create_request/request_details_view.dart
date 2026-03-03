import 'package:flutter/services.dart'; // Added
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../controllers/create_request_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../utils/widgets/buttons/secondary_button.dart';

class RequestDetailsView extends GetView<CreateRequestController> {
  const RequestDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppText.requestDetails, style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark, size: 24.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.amount,
                style: AppTextStyles.h2.copyWith(color: AppTextStyles.h2.color),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller.amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.amountDisplay.copyWith(
                  color: AppColors.textDark,
                  fontSize: 32.sp,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: AppTextStyles.amountDisplay.copyWith(
                    color: AppColors.textSlate.withOpacity(0.5),
                    fontSize: 32.sp,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 8.w),
                    child: Text(
                      '₹',
                      style: AppTextStyles.amountDisplay.copyWith(
                        color: AppColors.textDark,
                        fontSize: 32.sp,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                ),
              ),

              //SizedBox(height: 24.h),
              SizedBox(height: 16.h), // Reduced spacing
              // Dynamic Status Banner (Replaces Request Type Selector)
              Obx(() {
                if (controller.amount.value <= 0)
                  return const SizedBox.shrink(); // Hide until amount entered

                if (controller.category.value == 'Approval Required') {
                  // Warning Banner (Yellow)
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB), // Yellow 50
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFFEF3C7)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDE68A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: const Color(0xFFB45309),
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppText.approvalRequired,
                                style: TextStyle(
                                  color: const Color(0xFF78350F),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "Amount exceeds ${controller.deemedLimit.value > 0 ? 'auto-approval limit (₹${controller.deemedLimit.value.toStringAsFixed(0)})' : 'auto-approval limit'}",
                                style: TextStyle(
                                  color: const Color(0xFF92400E),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Deemed/Auto-Approved Banner (Green)
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5), // Emerald 50
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFD1FAE5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFA7F3D0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: const Color(0xFF047857),
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Deemed Approval",
                                style: TextStyle(
                                  color: const Color(0xFF065F46),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "This request is within limits and will be auto-approved.",
                                style: TextStyle(
                                  color: const Color(0xFF064E3B),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
              SizedBox(height: 24.h),

              Text(
                AppText.category,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      value: controller.selectedExpenseCategory.value,
                      hint: Text(
                        AppText.selectCategory,
                        style: AppTextStyles.hintText,
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSlate,
                        size: 24.sp,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      dropdownColor: Theme.of(context).cardColor,
                      items: controller.expenseCategories.map((cat) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: cat,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.infoBg,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  cat['icon'],
                                  color: AppColors.primaryBlue,
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                cat['name'],
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppTextStyles.h3.color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          controller.selectedExpenseCategory.value = val,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                AppText.purpose,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.purposeController,
                decoration: InputDecoration(
                  hintText: AppText.purposeHint,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                AppText.descriptionOptional,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppText.descriptionPlaceholder,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
              SizedBox(height: 24.h),

              // Payment Note (Optional)
              Text(
                'Payment Note (Optional)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.paymentNoteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Pay to UPI: yourname@upi',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
              SizedBox(height: 24.h),

              // Attachments Buttons

              Obx(() {
                if (controller.requestType.value.isEmpty) {
                  return Center(
                    child: Text(
                      "Please select a request type to upload attachments.",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSlate,
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate responsive width
                    // If too small (e.g. < 300), use full width. Else 2 columns.
                    final isSmall =
                        constraints.maxWidth < 300; // Arbitrary breakpoint
                    final itemWidth = isSmall
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12.w) / 2;

                    return Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: [

                        // 1. Upload QR (Always visible, single)
                        if (controller.qrFile.value == null)
                          SizedBox(
                            width: itemWidth,
                            child: SecondaryButton(
                              text: "Upload QR",
                              onPressed: () => _showAttachmentOptions(
                                context,
                                isQr: true,
                              ),
                              icon: Icon(
                                Icons.qr_code_scanner,
                                color: AppColors.primaryBlue,
                                size: 20.sp,
                              ),
                            ),
                          ),

                        // 2. Upload Receipt (Single, Post-approved only, disappears)
                        if (controller.requestType.value == 'Post-approved' &&
                            controller.receiptFile.value == null)
                          SizedBox(
                            width: itemWidth,
                            child: SecondaryButton(
                              text: "Upload Receipt",
                              onPressed: () => _showAttachmentOptions(
                                context,
                                isQr: false,
                                isReceipt: true,
                              ),
                              icon: Icon(
                                Icons.receipt,
                                color: AppColors.primaryBlue,
                                size: 20.sp,
                              ),
                            ),
                          ),

                        // 3. Upload Bill (Multiple, Always visible)
                        SizedBox(
                          width: itemWidth,
                          child: SecondaryButton(
                            text: AppText.uploadBill,
                            onPressed: () =>
                                _showAttachmentOptions(context, isQr: false),
                            icon: Icon(
                              Icons.upload_file,
                              color: AppColors.primaryBlue,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
              SizedBox(height: 16.h),

              // Attached Files List
              Obx(
                () => Column(
                  children: [
                    // QR File (always, if uploaded)
                    if (controller.qrFile.value != null)
                      _buildFileItem(
                        context,
                        "QR Code",
                        Icons.qr_code_2,
                        Colors.purple,
                        () => controller.removeQr(),
                      ),

                    // Receipt File (Post-approved)
                    if (controller.requestType.value == 'Post-approved' &&
                        controller.receiptFile.value != null)
                      _buildFileItem(
                        context,
                        "Receipt Uploaded",
                        Icons.receipt,
                        AppColors.primaryBlue,
                        () => controller.removeReceipt(),
                      ),

                    // Bill Files (Pre-approved)
                    if (controller.requestType.value == 'Pre-approved')
                      ...controller.attachedFiles.asMap().entries.map((entry) {
                        return _buildFileItem(
                          context,
                          entry.value.name,
                          Icons.description,
                          const Color(0xFF64748B),
                          () => controller.removeFile(entry.key),
                        );
                      }).toList(),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: AppText.reviewRequest,
                  onPressed: () {
                    if (controller.validateRequest()) {
                      Get.toNamed(AppRoutes.CREATE_REQUEST_REVIEW);
                    }
                  },
                  icon: Icon(Icons.check, color: Colors.white, size: 16.sp),
                ),
              ),
            ],
          ),
        ),
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Option",
              style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryBlue,
                  size: 24.sp,
                ),
              ),
              title: Text("Capture Image", style: AppTextStyles.bodyLarge),
              onTap: () {
                Get.back();
                controller.pickImage(
                  ImageSource.camera,
                  isQr: isQr,
                  isReceipt: isReceipt,
                );
              },
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppColors.primaryBlue,
                  size: 24.sp,
                ),
              ),
              title: Text(
                "Upload from Gallery",
                style: AppTextStyles.bodyLarge,
              ),
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

  Widget _buildFileItem(
    BuildContext context,
    String name,
    IconData icon,
    Color iconColor,
    VoidCallback onRemove,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTextStyles.bodyMedium.color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red, size: 20.sp),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
