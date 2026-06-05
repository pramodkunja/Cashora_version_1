import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';

/// Inline textarea card shown when the admin is composing another
/// clarification question.
class AdminClarStatusAskAgainField extends StatelessWidget {
  final TextEditingController controller;

  const AdminClarStatusAskAgainField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            maxLines: 5,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: AppText.explainWhy,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSlate.withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              AppText.makeItClear,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.sp,
                color: AppColors.textSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
