import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';

/// Centered "no requests" placeholder shown when a tab list is empty.
class AdminApprovalsEmptyState extends StatelessWidget {
  const AdminApprovalsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 56.sp, color: AppColors.slate300),
          SizedBox(height: 14.h),
          Text(
            AppText.noRequests,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSlate,
            ),
          ),
        ],
      ),
    );
  }
}
