import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../controllers/accountant_payments_controller.dart';

class PendingPaymentsTab extends StatelessWidget {
  const PendingPaymentsTab({Key? key}) : super(key: key);

  static const _purple = AppColors.primary;
  static const _purpleLight = Color(0xFFF0EDFF);
  static const _slate900 = AppColors.textDark;
  static const _slate500 = AppColors.textSlate;
  static const _slate300 = Color(0xFFCBD5E1);
  static const _green = AppColors.successGreen;
  static const _greenBg = Color(0xFFECFDF5);
  static const _amber = AppColors.warningOrange;
  static const _amberBg = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountantPaymentsController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const SkeletonListView();
      }

      final expenses = controller.pendingExpenses;
      double total = 0;
      for (final item in expenses) {
        total += (item['amount'] as num?)?.toDouble() ?? 0.0;
      }

      return SingleChildScrollView(
        controller: controller.pendingScroll,
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
        child: Column(
          children: [
            // Outstanding card (gradient)
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
                    color: _purple.withOpacity(0.22),
                    blurRadius: 20.r,
                    offset: Offset(0, 8.h),
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
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Total Outstanding',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${expenses.length} pending requests',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // List
            if (expenses.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 48.h),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 56.sp, color: _slate300),
                      SizedBox(height: 12.h),
                      Text(
                        'No pending payments',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _slate500,
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
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) => _buildItem(expenses[i]),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final id = item['request_id']?.toString() ?? '#REQ-${item['id']}';
    final date = _formatDate(item['created_at']?.toString());
    final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
    final category = item['category']?.toString() ?? 'Expense';

    String name = 'Unknown';
    if (item['requestor'] is Map) {
      final r = item['requestor'];
      name = '${r['first_name'] ?? ''} ${r['last_name'] ?? ''}'.trim();
      if (name.isEmpty) name = r['email']?.toString() ?? 'Unknown';
    }

    return GestureDetector(
      onTap: () async {
        await Get.toNamed(
          AppRoutes.ACCOUNTANT_PAYMENT_REQUEST_DETAILS,
          arguments: {'request': item},
        );
        // Reset scroll + refresh list when returning
        final ctrl = Get.find<AccountantPaymentsController>();
        ctrl.resetScroll();
        await ctrl.fetchPendingPayments();
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$id • $date',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: _slate500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: _purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      _initials(name),
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _purple,
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
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: _slate900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        category,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: _slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1.h, color: const Color(0xFFF1F5F9)),
            SizedBox(height: 10.h),
            Row(
              children: [
                _statusChip(
                  label: (item['status']?.toString() ?? 'APPROVED').toUpperCase(),
                  color: _green,
                  bg: _greenBg,
                ),
                SizedBox(width: 6.w),
                _statusChip(
                  label: (item['payment_status']
                              ?.toString()
                              .replaceAll('_', ' ')
                              .toUpperCase() ??
                          'PENDING'),
                  color: _amber,
                  bg: _amberBg,
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'View',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.chevron_right_rounded,
                        color: _purple, size: 18.sp),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return '';
    }
  }
}
