import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../controllers/accountant_dashboard_controller.dart';
import '../controllers/accountant_payments_controller.dart';
import 'tabs/completed_payments_tab.dart';
import 'tabs/pending_payments_tab.dart';
import 'tabs/generic_payment_list_tab.dart'; // Restoring removed import
import 'widgets/accountant_bottom_bar.dart'; // Added
import 'widgets/accountant_bottom_bar.dart';

// Revert imports
import 'tabs/completed_payments_tab.dart';
import 'tabs/pending_payments_tab.dart';
import 'widgets/accountant_bottom_bar.dart';

class AccountantPaymentsView extends GetView<AccountantPaymentsController> {
  const AccountantPaymentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false, // Prevent layout shift on keyboard
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Requests', style: AppTextStyles.h2),
            SizedBox(height: 4.h),
            Text('Accountant View', style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: Theme.of(context).iconTheme.color,
              size: 24.sp,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70.h), // Increased height for spacing
          child: Container(
            margin: EdgeInsets.fromLTRB(
              20.w,
              12.h,
              20.w,
              10.h,
            ), // Added top margin for space after Accountant View
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(30.r),
            ),
            clipBehavior:
                Clip.antiAlias, // Ensure child (indicator) clips perfectly
            child: TabBar(
              controller: controller.tabController,
              indicatorSize: TabBarIndicatorSize.tab, // Fill the entire tab
              indicator: BoxDecoration(
                color: AppColors.primaryBlue, // Blue to fill as requested
                borderRadius: BorderRadius.circular(30.r),
                // Remove Shadow if it looks like a "line"
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSlate,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.sp,
              ),
              dividerColor: Colors.transparent, // Remove any bottom line
              indicatorPadding: EdgeInsets.zero, // Ensure no padding
              labelPadding: EdgeInsets
                  .zero, // Ensure full width tap target (optional, but good for fill)

              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: const [PendingPaymentsTab(), CompletedPaymentsTab()],
      ),
    );
  }
}
