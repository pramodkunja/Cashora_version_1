import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/accountant_payments_controller.dart';
import 'tabs/completed_payments_tab.dart';
import 'tabs/pending_payments_tab.dart';

class AccountantPaymentsView extends GetView<AccountantPaymentsController> {
  const AccountantPaymentsView({super.key});


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundAlt,
        body: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: const [
                  PendingPaymentsTab(),
                  CompletedPaymentsTab(),
                ],
              ),
            ),
          ],
        ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Requests',
                  style: GoogleFonts.inter(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Accountant View',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
      child: Container(
        height: 44.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: TabBar(
          onTap: (index) {
            controller.resetScroll();
            if (index == 0) {
              controller.fetchPendingPayments();
            } else {
              controller.fetchCompletedPayments();
            }
          },
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6.r,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSlate,
          labelStyle: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
          dividerColor: Colors.transparent,
          overlayColor:
              WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
    );
  }
}
