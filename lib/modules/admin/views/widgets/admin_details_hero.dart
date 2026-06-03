import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/formatters/currency_formatter.dart';

/// Gradient hero card at the top of the Admin Request Details screen.
///
/// Shows the back button, screen title, status pill, big amount, request
/// id and (optionally) category + request-type chips. Colors and the
/// status icon/label come in as parameters so the parent variant style
/// stays private to the screen.
class AdminDetailsHero extends StatelessWidget {
  final Color gradientStart;
  final Color gradientEnd;
  final IconData statusIcon;
  final String statusLabel;
  final double amount;
  final String requestId;
  final String category;
  final String requestType;

  const AdminDetailsHero({
    super.key,
    required this.gradientStart,
    required this.gradientEnd,
    required this.statusIcon,
    required this.statusLabel,
    required this.amount,
    required this.requestId,
    required this.category,
    required this.requestType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 12.h,
        20.w,
        22.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
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
                  AppText.requestDetails,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 13.sp),
                    SizedBox(width: 5.w),
                    Text(
                      statusLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${CurrencyFormatter.inr(amount)}',
              maxLines: 1,
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 40.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'REQUEST ID #$requestId',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
              letterSpacing: 0.5,
            ),
          ),
          if (category.isNotEmpty || requestType.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (category.isNotEmpty)
                  _chip(label: category, icon: Icons.label_outline_rounded),
                if (requestType.isNotEmpty)
                  _chip(
                    label: requestType,
                    icon: Icons.assignment_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip({required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
