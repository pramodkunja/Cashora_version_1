import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text_styles.dart';
import '../../../controllers/payment_flow_controller.dart';
import 'bill_details_scanner_animation.dart';

class BillDetailsImagePreview extends StatelessWidget {
  const BillDetailsImagePreview({super.key, required this.controller});

  final PaymentFlowController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Container(
            width: 0.9.sw,
            constraints: BoxConstraints(maxHeight: 0.8.sh),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 20.r,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Image Display
                Obx(() {
                  // Priority: Controller State -> Get.arguments -> Empty
                  String url = controller.currentImageUrl.value;
                  if (url.isEmpty &&
                      Get.arguments != null &&
                      Get.arguments['url'] != null) {
                    url = Get.arguments['url'];
                    // Auto-fix controller state if it was missed
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.currentImageUrl.value = url;
                    });
                  }

                  if (url.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 48.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "No Image Available",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSlate,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        url,
                        fit: BoxFit.contain,
                        loadingBuilder:
                            (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                        errorBuilder: (context, error, stackTrace) {
                          if (kDebugMode) {
                            debugPrint("Image Load Error for $url: $error");
                          }
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 48.sp,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Failed to load image",
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: Colors.redAccent),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  error.toString(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),

                // Scanning Animation (Only if QR Mode & Scanning)
                Obx(() {
                  if (controller.isQrMode.value &&
                      controller.isScanning.value) {
                    return Positioned.fill(
                      child: IgnorePointer(child: ScannerAnimation()),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
