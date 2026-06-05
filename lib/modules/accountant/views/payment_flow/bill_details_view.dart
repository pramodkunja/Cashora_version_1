import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/payment_flow_controller.dart';
import 'widgets/bill_details_downloader.dart';
import 'widgets/bill_details_image_preview.dart';
import 'widgets/bill_details_qr_popup.dart';

class BillDetailsView extends GetView<PaymentFlowController> {
  const BillDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
            size: 24.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.currentTitle.value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        actions: [
          Obx(() {
            final url = controller.currentImageUrl.value;
            if (url.isNotEmpty && url.startsWith('http')) {
              return IconButton(
                icon: Icon(Icons.download, color: Theme.of(context).iconTheme.color),
                onPressed: () => BillDetailsDownloader.downloadImage(context, url),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main Content (Bill Preview)
          BillDetailsImagePreview(controller: controller),

          // Loading Overlay
          Obx(
            () => controller.isScanning.value
                ? Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Analyzing QR..."),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),

          Obx(() {
            if (controller.isQrDetected.isTrue) {
              return BillDetailsQrPopup(controller: controller);
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}
