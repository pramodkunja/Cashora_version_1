import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';

class AdminBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppTextStyles.bodySmall.color,
        selectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
          fontSize: 12.sp,
        ),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 24.sp),
            label: AppText.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_rounded, size: 24.sp),
            label: AppText.navApprovals,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded, size: 24.sp),
            label: AppText.navHistory,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 24.sp),
            label: AppText.navProfile,
          ),
        ],
      ),
    );
  }
}
