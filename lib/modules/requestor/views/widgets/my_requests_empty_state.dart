import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';

/// Centered empty state shown when no requests match the active filter
/// / search in the Requestor "My Requests" screen.
class MyRequestsEmptyState extends StatelessWidget {
  const MyRequestsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 56.sp, color: AppColors.slate300),
          SizedBox(height: 14.h),
          Text(
            'No requests found',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSlate,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap the + button to create one',
            style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.slate300),
          ),
        ],
      ),
    );
  }
}
