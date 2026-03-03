import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';

class AdminOverviewCard extends StatelessWidget {
  final String title;
  final String count;
  final bool isMoney;

  const AdminOverviewCard({
    Key? key,
    required this.title,
    required this.count,
    required this.isMoney,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r), // Responsive
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r), // Responsive
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16.r, // Responsive
            offset: Offset(0, 4.h), // Responsive
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTextStyles.bodySmall.color,
            ),
          ),
          SizedBox(height: 8.h), // Responsive
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: AppTextStyles.h1.copyWith(
                color: isMoney ? AppColors.primaryBlue : AppTextStyles.h1.color,
                fontSize: 28.sp, // Responsive
              ),
            ),
          ),
        ],
      ),
    );
  }
}
