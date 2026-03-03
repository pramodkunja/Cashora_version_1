import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/app_loader.dart';

class GenericPaymentListTab extends StatelessWidget {
  final RxList<Map<String, dynamic>> dataList;
  final String emptyMessage;
  final Color statusColor;
  final String statusLabel;

  const GenericPaymentListTab({
    Key? key,
    required this.dataList,
    required this.emptyMessage,
    required this.statusColor,
    required this.statusLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (dataList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48.sp,
                color: AppColors.textSlate.withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              Text(
                emptyMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSlate,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: dataList.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final item = dataList[index];
          final request = item['requestor'] ?? {};
          final String name =
              "${request['first_name'] ?? ''} ${request['last_name'] ?? ''}"
                  .trim();

          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#REQ-${item['id']}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSlate,
                      ),
                    ),
                    Text(
                      '₹${item['amount']?.toString() ?? '0.00'}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  name.isNotEmpty ? name : (request['email'] ?? 'Unknown User'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item['category'] ?? 'General',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSlate,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
