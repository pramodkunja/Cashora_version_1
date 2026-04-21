import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/monthly_spent_controller.dart';
import '../../../../utils/app_colors.dart';

class MonthlySpentView extends StatelessWidget {
  const MonthlySpentView({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _bg = Color(0xFFF8FAFC);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _red = AppColors.errorRed;
  static const _redBg = Color(0xFFFEF2F2);
  static const _amber = AppColors.warningOrange;
  static const _amberBg = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MonthlySpentController());
    final controller = Get.find<MonthlySpentController>();

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context, controller),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      style: GoogleFonts.inter(
                          fontSize: 14.sp, color: _slate900),
                      decoration: InputDecoration(
                        hintText: 'Search transactions',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 14.sp, color: _slate300),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: _slate500, size: 20.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(
                      () => Row(
                        children: [
                          _chip(controller, 'All', 0),
                          SizedBox(width: 8.w),
                          _chip(controller, 'Paid', 1),
                          SizedBox(width: 8.w),
                          _chip(controller, 'Pending', 2),
                          SizedBox(width: 8.w),
                          _chip(controller, 'Rejected', 3),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Transactions list
                  Obx(() {
                    final items = controller.displayedTransactions;
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.h),
                          child: Column(
                            children: [
                              Icon(Icons.inbox_rounded,
                                  size: 48.sp, color: _slate300),
                              SizedBox(height: 12.h),
                              Text(
                                'No transactions found',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _slate500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: items.map((tx) => _txCard(tx)).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header with total card ───────────────────────────────────────
  Widget _buildHeader(BuildContext context, MonthlySpentController ctrl) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 14.h,
        20.w,
        26.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C68D4), Color(0xFF5B45B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                'Monthly Spent',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Month navigation
          Row(
            children: [
              GestureDetector(
                onTap: ctrl.previousMonth,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_left_rounded,
                      color: Colors.white, size: 18.sp),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: ctrl.selectMonthYear,
                  child: Obx(
                    () => Center(
                      child: Text(
                        ctrl.currentMonth.value,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: ctrl.nextMonth,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_right_rounded,
                      color: Colors.white, size: 18.sp),
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          // Total spent
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spent',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹${ctrl.totalSpent.value.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_down_rounded,
                          color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        ctrl.comparisonText.value,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(MonthlySpentController ctrl, String label, int index) {
    final selected = ctrl.selectedFilterIndex.value == index;
    return GestureDetector(
      onTap: () => ctrl.changeFilter(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? _purple : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _slate500,
          ),
        ),
      ),
    );
  }

  Widget _txCard(Map<String, dynamic> tx) {
    final status = (tx['status'] ?? 'Pending').toString();
    final title = tx['title']?.toString() ?? '';
    final date = tx['date']?.toString() ?? '';
    final amount = tx['amount']?.toString() ?? '';
    final icon = (tx['icon'] as IconData?) ?? Icons.receipt_long_rounded;

    Color statusColor;
    Color statusBg;
    switch (status) {
      case 'Paid':
        statusColor = _green;
        statusBg = _greenBg;
        break;
      case 'Rejected':
        statusColor = _red;
        statusBg = _redBg;
        break;
      default:
        statusColor = _amber;
        statusBg = _amberBg;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
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
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: _purple, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _slate900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: _slate500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: _slate900,
                ),
              ),
              SizedBox(height: 5.h),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
