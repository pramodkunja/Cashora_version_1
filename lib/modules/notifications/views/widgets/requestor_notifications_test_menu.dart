import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/fcm_service.dart';

class RequestorNotificationsTestMenu {
  const RequestorNotificationsTestMenu._();

  static void show(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Inject Test Notification',
                style: GoogleFonts.inter(
                    fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            _testButton('Expense Approved', 'expense_approved'),
            _testButton('Expense Rejected', 'expense_rejected'),
            _testButton('Clarification Required', 'clarification_required'),
            _testButton('Clarification Responded', 'clarification_responded'),
            _testButton('Expense Paid', 'expense_paid'),
          ],
        ),
      ),
    );
  }

  static Widget _testButton(String label, String type) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Get.find<FCMService>().injectTestNotification(eventType: type);
        Get.back();
      },
    );
  }
}
