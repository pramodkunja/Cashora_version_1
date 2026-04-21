import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/auth_service.dart';
import '../../controllers/create_request_controller.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/app_loader.dart';

class ReviewRequestView extends GetView<CreateRequestController> {
  const ReviewRequestView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                children: [
                  // Total Amount Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(22.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B55CE), Color(0xFF8B74E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withOpacity(0.25),
                          blurRadius: 20.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppText.totalRequestedAmount,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.85),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Obx(
                          () => Text(
                            '₹${controller.amount.value.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 38.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Request Details Card
                  _buildSectionCard(
                    icon: Icons.description_rounded,
                    title: AppText.requestDetails,
                    children: [
                      _detailRow(
                        Icons.person_rounded,
                        'Requestor',
                        Get.find<AuthService>().currentUser.value?.name ??
                            'Unknown',
                      ),
                      Obx(() => _detailRow(
                            Icons.receipt_long_rounded,
                            AppText.requestType,
                            controller.requestType.value,
                          )),
                      Obx(() {
                        final cat = controller.selectedExpenseCategory.value;
                        return _detailRow(
                          Icons.category_rounded,
                          AppText.category,
                          cat?['name'] ?? AppText.notSelected,
                        );
                      }),
                      Obx(() => _detailRow(
                            Icons.label_rounded,
                            AppText.purpose,
                            controller.purpose.value,
                          )),
                      Obx(() => _detailRow(
                            Icons.notes_rounded,
                            AppText.description,
                            controller.description.value,
                            last: true,
                          )),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Attachments Card
                  _buildSectionCard(
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
                                color: _slate500,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: allFiles.map((file) {
                            final isQr = file == controller.qrFile.value;
                            final isReceipt =
                                file == controller.receiptFile.value;
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
                                onTap: () =>
                                    _showImagePreview(Get.context!, file),
                                child: Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: _bg,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: _purpleLight,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(icon,
                                            color: _purple, size: 18.sp),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              label,
                                              style: GoogleFonts.inter(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                                color: _slate900,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (isQr || isReceipt)
                                              Text(
                                                file.name,
                                                style: GoogleFonts.inter(
                                                  fontSize: 10.sp,
                                                  color: _slate500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.visibility_rounded,
                                          color: _slate500, size: 16.sp),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
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
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            AppText.reviewRequest,
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

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.submitRequest,
              icon: controller.isLoading.value
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.send_rounded, size: 18.sp),
              label: Text(
                controller.isLoading.value
                    ? 'Submitting...'
                    : AppText.submitRequest,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _purple.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: _purple, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _slate900,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: _purple, size: 15.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: _slate500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value.isEmpty ? '-' : value,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _slate900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                    return SizedBox(
                      height: 200.h,
                      child: const AppLoader(),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 200.h,
                      child: const Center(child: Text('Error loading preview')),
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
