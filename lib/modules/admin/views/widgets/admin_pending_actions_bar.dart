import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../utils/widgets/buttons/secondary_button.dart';

/// Sticky bottom action bar shown for pending requests on the Admin
/// Request Details screen. Three actions: Ask Clarification (full-width
/// outlined) → Reject (red) / Approve (primary) side-by-side below.
///
/// Pure presentation: callbacks are passed in so the widget has no
/// controller dependency.
class AdminPendingActionsBar extends StatelessWidget {
  final VoidCallback onAskClarification;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  const AdminPendingActionsBar({
    super.key,
    required this.onAskClarification,
    required this.onReject,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14.r,
            offset: Offset(0, -3.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SecondaryButton(
              text: AppText.askClarification,
              onPressed: onAskClarification,
              backgroundColor: Colors.transparent,
              textColor: AppColors.primaryBlue,
              border: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.5,
              ),
              width: double.infinity,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: AppText.reject,
                    onPressed: onReject,
                    backgroundColor: const Color(0xFFFEE2E2),
                    textColor: const Color(0xFFB91C1C),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryButton(
                    text: AppText.approve,
                    onPressed: onApprove,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
