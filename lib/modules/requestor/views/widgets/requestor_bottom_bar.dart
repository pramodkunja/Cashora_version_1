import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_text.dart';
import '../../../../utils/app_colors.dart';

class RequestorBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const RequestorBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary, // Deep Purple
        unselectedItemColor: AppColors.textLight, // Slate 400
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12.sp), // Responsive label
        unselectedLabelStyle: TextStyle(fontSize: 12.sp), // Responsive label
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded, size: 24.sp),
            label: AppText.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded, size: 24.sp),
            label: AppText.requests,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 24.sp),
            label: AppText.profile,
          ),
        ],
      ),
    );
  }
}
