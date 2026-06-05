import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';

class ProvideClarificationRequestCard extends StatelessWidget {
  const ProvideClarificationRequestCard({
    super.key,
    required this.request,
  });

  final Map request;

  @override
  Widget build(BuildContext context) {
    String userName = AppText.unknownUser;
    if (request['employee_name'] != null) {
      userName = request['employee_name'];
    } else if (request['created_by_name'] != null) {
      userName = request['created_by_name'];
    } else if (request['user'] != null) {
      if (request['user'] is String) {
        userName = request['user'];
      } else if (request['user'] is Map &&
          request['user']['name'] != null) {
        userName = request['user']['name'];
      }
    } else if (request['requestor_name'] != null) {
      userName = request['requestor_name'];
    } else if (request['requestor'] is Map) {
      final r = request['requestor'];
      userName =
          '${r['first_name'] ?? ''} ${r['last_name'] ?? ''}'.trim();
      if (userName.isEmpty) userName = r['email']?.toString() ?? 'Unknown';
    }

    final category =
        request['category']?.toString() ?? request['title']?.toString() ?? AppText.expense;
    final amount = (request['amount'] is num)
        ? (request['amount'] as num).toDouble()
        : double.tryParse(request['amount']?.toString() ?? '0') ?? 0.0;
    final receiptUrl = request['receipt_url']?.toString();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSlate,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.purpleSurface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: AppColors.purpleSurface,
              borderRadius: BorderRadius.circular(14.r),
              image: receiptUrl != null && receiptUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(receiptUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (receiptUrl == null || receiptUrl.isEmpty)
                ? Icon(Icons.receipt_long_rounded,
                    color: AppColors.primary, size: 28.sp)
                : null,
          ),
        ],
      ),
    );
  }
}
