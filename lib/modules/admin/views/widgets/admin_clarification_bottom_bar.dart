import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../controllers/admin_clarification_status_controller.dart';

/// Sticky bottom bar for the Admin Clarification Status screen.
///
/// Switches three layouts based on [state]:
/// - `responded` → outlined Ask-Again + red Reject + blue Approve row
/// - `askingAgain` → solid Send-Clarification primary button
/// - `pending` → outlined Ask-Another-Question button
///
/// Extracted from `admin_clarification_status_view.dart`. Pure
/// presentation — the three actions come in as callbacks.
class AdminClarificationBottomBar extends StatelessWidget {
  final ClarificationState state;
  final VoidCallback onAskAgain;
  final VoidCallback onSubmitAskAgain;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  const AdminClarificationBottomBar({
    super.key,
    required this.state,
    required this.onAskAgain,
    required this.onSubmitAskAgain,
    required this.onReject,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    if (state == ClarificationState.responded) {
      return _shell(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: onAskAgain,
                icon: Icon(Icons.help_outline_rounded,
                    color: AppColors.primaryBlue, size: 18.sp),
                label: Text(
                  AppText.askClarification,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: AppColors.primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        AppText.reject,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: Icon(Icons.check,
                          color: Colors.white, size: 18.sp),
                      label: Text(
                        AppText.approve,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (state == ClarificationState.askingAgain) {
      return _shell(
        PrimaryButton(
          text: AppText.sendClarificationRequest,
          onPressed: onSubmitAskAgain,
          icon: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
        ),
      );
    }

    // pending — admin may want to add a follow-up question while waiting.
    return _shell(
      SizedBox(
        width: double.infinity,
        height: 52.h,
        child: OutlinedButton.icon(
          onPressed: onAskAgain,
          icon: Icon(Icons.help_outline_rounded,
              color: AppColors.primaryBlue, size: 18.sp),
          label: Text(
            'Ask Another Question',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side:
                const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shell(Widget child) {
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
      child: SafeArea(top: false, child: child),
    );
  }
}
