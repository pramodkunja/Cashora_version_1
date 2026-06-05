import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import '../controllers/manage_balances_controller.dart';
import 'widgets/manage_balances_header.dart';
import 'widgets/manage_balances_summary_card.dart';
import 'widgets/manage_balances_edit_card.dart';
import 'widgets/manage_balances_history_card.dart';

/// Manage Balances — accountant's profile-side screen for viewing and
/// editing the opening / closing balance of the day plus seeing history.
class ManageBalancesView extends GetView<ManageBalancesController> {
  const ManageBalancesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ManageBalancesHeader(controller: controller),
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
                      Obx(() => ManageBalancesSummaryCard(
                            controller: controller,
                          )),
                      SizedBox(height: 18.h),
                      _sectionLabel('UPDATE BALANCE'),
                      SizedBox(height: 10.h),
                      ManageBalancesEditCard(controller: controller),
                      SizedBox(height: 18.h),
                      _sectionLabel('HISTORY'),
                      SizedBox(height: 10.h),
                      Obx(() => ManageBalancesHistoryCard(
                            controller: controller,
                          )),
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
