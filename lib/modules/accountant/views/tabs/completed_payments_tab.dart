import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/accountant_payments_controller.dart';

class CompletedPaymentsTab extends StatelessWidget {
  const CompletedPaymentsTab({super.key});


  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountantPaymentsController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const SkeletonListView();
      }
      final expenses = controller.completedExpenses;
      double total = 0;
      for (final item in expenses) {
        total += double.tryParse(
              item['amount_paid']?.toString() ??
                  item['amount']?.toString() ??
                  '0',
            ) ??
            0;
      }

      return SingleChildScrollView(
        controller: controller.completedScroll,
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
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
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: TextField(
                style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: AppText.searchByIdOrName,
                  hintStyle:
                      GoogleFonts.inter(fontSize: 14.sp, color: AppColors.slate300),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textSlate, size: 20.sp),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Total Disbursed card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.mintBg,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.payments_rounded,
                        color: AppColors.successGreen, size: 24.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.totalDisbursed,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSlate,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                'RECENT COMPLETED',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSlate,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 10.h),

            if (expenses.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 28.h),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 56.sp, color: AppColors.slate300),
                      SizedBox(height: 12.h),
                      Text(
                        'No completed payments',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSlate,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (_, i) => _buildItem(expenses[i]),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final amount = double.tryParse(
          item['amount_paid']?.toString() ??
              item['amount']?.toString() ??
              '0',
        ) ??
        0.0;

    final dateStr = item['processed_at'] ??
        item['created_at'] ??
        item['updated_at'];
    String formattedDate = '';
    if (dateStr != null) {
      try {
        final dt = DateTime.parse(dateStr);
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        formattedDate = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      } catch (_) {
        formattedDate = dateStr.toString().split('T')[0];
      }
    }

    String title = 'Unknown User';
    if (item['requestor'] is Map) {
      final r = item['requestor'];
      title = '${r['first_name'] ?? ''} ${r['last_name'] ?? ''}'.trim();
      if (title.isEmpty) title = r['email']?.toString() ?? 'Unknown';
    } else if (item['payee_name'] != null) {
      title = item['payee_name'].toString();
    } else {
      title = item['request_id']?.toString() ?? 'Payment #${item['id']}';
    }

    final subtitle = (item['payment_source'] ?? item['category'] ?? '').toString();
    final id = (item['request_id'] ?? item['payment_id'] ?? item['id'] ?? '')
        .toString()
        .toUpperCase();

    return GestureDetector(
      onTap: () async {
        await Get.toNamed(
          AppRoutes.ACCOUNTANT_PAYMENT_COMPLETED_DETAILS,
          arguments: item,
        );
        final ctrl = Get.find<AccountantPaymentsController>();
        ctrl.resetScroll();
        await ctrl.fetchCompletedPayments();
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
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
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      id,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSlate,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.mintBg,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    AppText.completedSC,
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColors.purpleSurface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      _initials(title),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: AppColors.textSlate,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 12.sp, color: AppColors.textSlate),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textSlate,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.slate300, size: 18.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
