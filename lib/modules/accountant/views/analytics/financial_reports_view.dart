import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/skeletons/page_skeletons.dart';
import '../../controllers/accountant_analytics_controller.dart';
import 'widgets/financial_preview.dart';
import 'widgets/financial_parameters_card.dart';

class FinancialReportsView extends GetView<AccountantAnalyticsController> {
  const FinancialReportsView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              child: Column(
                children: [
                  FinancialParametersCard(controller: controller),
                  SizedBox(height: 16.h),
                  _previewCard(),
                  SizedBox(height: 16.h),
                  _exportButtons(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
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
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              AppText.financialReports,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded,
                color: Colors.white, size: 20.sp),
          ),
        ],
      ),
    );
  }
  Widget _previewCard() {
    return Obx(() {
      if (controller.isReportLoading.value &&
          controller.reportSummary.value == null) {
        return const ReportsPreviewSkeleton();
      }
      if (controller.errorMessage.isNotEmpty &&
          controller.reportSummary.value == null) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Text(
              controller.errorMessage.value,
              style: GoogleFonts.inter(
                  fontSize: 13.sp, color: AppColors.errorRed),
            ),
          ),
        );
      }
      final summary = controller.reportSummary.value?.previewSummary;
      if (summary == null) {
        return Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.analytics_outlined,
                    size: 40.sp, color: AppColors.slate300),
                SizedBox(height: 10.h),
                Text(
                  'Generate preview to see results',
                  style: GoogleFonts.inter(
                      fontSize: 13.sp, color: AppColors.textSlate),
                ),
              ],
            ),
          ),
        );
      }

      return FinancialPreview(summary: summary);
    });
  }

  Widget _exportButtons() {
    return Obx(() {
      final enabled = controller.exportsAvailable.value;
      const disabledTooltip = 'Export is coming soon';
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: Tooltip(
                message: enabled ? '' : disabledTooltip,
                child: OutlinedButton.icon(
                  onPressed: enabled ? controller.exportCsv : null,
                  icon: Icon(Icons.table_chart_rounded,
                      color: enabled ? AppColors.primary : Colors.grey, size: 16.sp),
                  label: Text(
                    AppText.exportCsv,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: enabled ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                    backgroundColor: AppColors.purpleSurface.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: Tooltip(
                message: enabled ? '' : disabledTooltip,
                child: ElevatedButton.icon(
                  onPressed: enabled ? controller.exportPdf : null,
                  icon: Icon(Icons.picture_as_pdf_rounded, size: 16.sp),
                  label: Text(
                    AppText.exportPdf,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
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
          ),
        ],
      );
    });
  }
}
