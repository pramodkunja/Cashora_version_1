import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../utils/app_colors.dart';

class BillDetailsDownloader {
  const BillDetailsDownloader._();

  static Future<void> downloadImage(BuildContext context, String url) async {
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }
      if (!hasAccess) {
        if (context.mounted) {
          Get.snackbar(
            'Permission Denied',
            'Cannot save image without gallery access',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.warningOrange.withValues(alpha: 0.9),
            colorText: Colors.white,
            margin: EdgeInsets.all(16.w),
          );
        }
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        barrierDismissible: false,
      );

      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Dio().download(url, savePath);
      await Gal.putImage(savePath);

      if (Get.isDialogOpen ?? false) {
        Get.back(); // close dialog
      }

      Get.snackbar(
        'Success',
        'Image saved to gallery successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successGreen.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) debugPrint("Download Image Error: $e\n$stackTrace");
      if (Get.isDialogOpen ?? false) {
        Get.back(); // close dialog if open
      }
      Get.snackbar(
        'Error',
        'Failed to save image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningOrange.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
      );
    }
  }
}
