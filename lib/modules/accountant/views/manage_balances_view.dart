import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import 'package:cash/utils/formatters/currency_formatter.dart';
import '../../../../utils/date_helper.dart';
import '../controllers/manage_balances_controller.dart';

/// Manage Balances — accountant's profile-side screen for viewing and
/// editing the opening / closing balance of the day plus seeing history.
class ManageBalancesView extends GetView<ManageBalancesController> {
  const ManageBalancesView({super.key});

  static const _slate600 = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.refreshAll,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => _buildSummaryCard()),
                      SizedBox(height: 18.h),
                      _sectionLabel('UPDATE BALANCE'),
                      SizedBox(height: 10.h),
                      _buildEditCard(),
                      SizedBox(height: 18.h),
                      _sectionLabel('HISTORY'),
                      SizedBox(height: 10.h),
                      Obx(() => _buildHistoryCard()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        24.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Manage Balances',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Obx(() {
            final dt = controller.today.value;
            if (dt.isEmpty) return const SizedBox.shrink();
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                DateHelper.formatDateTime(dt, fallback: dt).split(',').first,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Summary card ───────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _bigStat(
                  label: 'OPENING',
                  value: controller.openingBalance.value,
                  color: AppColors.primary,
                ),
              ),
              Container(width: 1, height: 56.h, color: AppColors.slate100),
              Expanded(
                child: _bigStat(
                  label: 'CLOSING',
                  value: controller.closingBalance.value,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(height: 1, color: AppColors.slate100),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  icon: Icons.south_west_rounded,
                  label: 'In',
                  value: controller.amountIn.value,
                  color: AppColors.successGreen,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _miniStat(
                  icon: Icons.north_east_rounded,
                  label: 'Out',
                  value: controller.amountOut.value,
                  color: AppColors.warningOrange,
                ),
              ),
            ],
          ),
          if (controller.note.value.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFFEF3C7)),
              ),
              child: Row(
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 14.sp, color: const Color(0xFFB45309)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      controller.note.value,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bigStat({
    required String label,
    required double value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSlate,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${CurrencyFormatter.inr(value)}',
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 14.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: AppColors.textSlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '₹${CurrencyFormatter.inr(value)}',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Edit form ──────────────────────────────────────────────────────────
  Widget _buildEditCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField(
            label: 'Opening balance',
            controller: controller.openingController,
            prefix: '₹',
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            required: true,
          ),
          SizedBox(height: 12.h),
          _textField(
            label: 'Closing balance (optional)',
            controller: controller.closingController,
            prefix: '₹',
            keyboard: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 12.h),
          _textField(
            label: 'Note (optional)',
            controller: controller.noteController,
            hint: 'e.g. cash deposit from main vault',
            keyboard: TextInputType.text,
            maxLines: 2,
          ),
          SizedBox(height: 16.h),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed:
                    controller.isSaving.value ? null : controller.saveBalance,
                icon: controller.isSaving.value
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.save_rounded, size: 18.sp),
                label: Text(
                  controller.isSaving.value ? 'Saving…' : 'Save changes',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? prefix,
    TextInputType? keyboard,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _slate600,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.errorRed,
                ),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
            decoration: InputDecoration(
              prefixText: prefix,
              prefixStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSlate,
                fontWeight: FontWeight.w600,
              ),
              hintText: hint,
              hintStyle:
                  GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textSlate),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  // ── History ─────────────────────────────────────────────────────────────
  Widget _buildHistoryCard() {
    if (controller.isHistoryLoading.value && controller.history.isEmpty) {
      return Container(
        padding: EdgeInsets.all(18.w),
        decoration: _cardDecoration(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (controller.history.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: _cardDecoration(),
        child: Center(
          child: Text(
            'No balance history yet',
            style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSlate),
          ),
        ),
      );
    }
    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: controller.history.asMap().entries.map((e) {
          final isLast = e.key == controller.history.length - 1;
          return Column(
            children: [
              _historyRow(e.value),
              if (!isLast) Container(height: 1, color: AppColors.slate100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _historyRow(Map<String, dynamic> item) {
    final date = item['date']?.toString() ?? '';
    final opening = (item['opening_balance'] as num?)?.toDouble() ?? 0;
    final closing = (item['closing_balance'] as num?)?.toDouble() ?? 0;
    final delta = closing - opening;
    final updatedBy = item['updated_by']?.toString() ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDFF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateHelper.formatDateTime(date, fallback: date).split(',').first,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (updatedBy.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Updated by $updatedBy',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textSlate,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${CurrencyFormatter.inr(closing)}',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${delta >= 0 ? '+' : ''}₹${CurrencyFormatter.inr(delta.abs())}',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: delta >= 0 ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12.r,
          offset: Offset(0, 3.h),
        ),
      ],
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
          color: AppColors.textSlate,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

}
