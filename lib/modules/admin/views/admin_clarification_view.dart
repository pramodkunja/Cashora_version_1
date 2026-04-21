import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../controllers/admin_request_details_controller.dart';

class AdminClarificationView extends GetView<AdminRequestDetailsController> {
  const AdminClarificationView({Key? key}) : super(key: key);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('REQUEST DETAILS'),
                  SizedBox(height: 10.h),
                  _buildRequestCard(),
                  SizedBox(height: 24.h),
                  _sectionLabel('YOUR QUESTION'),
                  SizedBox(height: 10.h),
                  _buildQuestionCard(),
                  SizedBox(height: 16.h),
                  _buildTip(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────
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
            AppText.askClarificationTitle,
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

  // ── Request Summary Card ─────────────────────────────────────────────
  Widget _buildRequestCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final req = controller.request;
                      final user = req['user']?.toString() ??
                          req['employee_name']?.toString() ??
                          req['created_by']?.toString() ??
                          AppText.unknownUser;
                      return Text(
                        user,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: _slate900,
                        ),
                      );
                    }),
                    SizedBox(height: 4.h),
                    Obx(() {
                      final req = controller.request;
                      final title = req['title']?.toString() ??
                          req['purpose']?.toString() ??
                          AppText.expense;
                      return Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: _slate500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() {
                final req = controller.request;
                String? imageUrl;
                if (req['receipt_url'] != null &&
                    req['receipt_url'].toString().isNotEmpty) {
                  imageUrl = req['receipt_url'].toString();
                } else if (req['attachments'] is List &&
                    (req['attachments'] as List).isNotEmpty) {
                  final first = (req['attachments'] as List).first;
                  if (first is String) imageUrl = first;
                  if (first is Map) {
                    imageUrl = first['url'] ?? first['file'] ?? first['path'];
                  }
                }

                if (imageUrl != null &&
                    (imageUrl.endsWith('.jpg') ||
                        imageUrl.endsWith('.png') ||
                        imageUrl.endsWith('.jpeg'))) {
                  return Container(
                    height: 72.h,
                    width: 72.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
                return Container(
                  height: 72.h,
                  width: 72.w,
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: _purple, size: 28.sp),
                );
              }),
            ],
          ),
          SizedBox(height: 14.h),
          Obx(() {
            final req = controller.request;
            final amount = (req['amount'] is num)
                ? (req['amount'] as num).toDouble()
                : double.tryParse(req['amount']?.toString() ?? '0') ?? 0.0;
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _purpleLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.currency_rupee_rounded,
                      color: _purple, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Amount',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _purple,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: _purple,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Question Card ────────────────────────────────────────────────────
  Widget _buildQuestionCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
                child: Icon(Icons.help_outline_rounded,
                    color: _purple, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'What do you need clarified?',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: _slate900,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: controller.clarificationController,
              maxLines: 6,
              style: GoogleFonts.inter(fontSize: 14.sp, color: _slate900),
              decoration: InputDecoration(
                hintText: AppText.clarificationHint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: _slate300,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _purpleLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_rounded,
              color: _purple, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Be specific — clear questions get faster responses.',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _purple,
              ),
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
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: () => controller.submitClarification(),
            icon: Icon(Icons.send_rounded, size: 18.sp),
            label: Text(
              AppText.sendBackForClarification,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
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

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: _slate500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
