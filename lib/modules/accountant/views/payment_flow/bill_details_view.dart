import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../controllers/payment_flow_controller.dart'; // Correct relative import

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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main Content (Bill Preview)
          Positioned.fill(
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
                        color: Colors.white.withOpacity(0.1),
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
                                print("Image Load Error for $url: $error");
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
          ),

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
              return _buildQrDetectedPopup();
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildQrDetectedPopup() {
    final details = controller.scannedDetails;
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFB2EBF2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.paymentDetailsFound,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Verified UPI QR",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                _buildDetailRow(
                  AppText.payeeName,
                  details['pn'] ?? 'Unknown',
                  boldValue: true,
                ),
                Divider(height: 24.h),
                _buildDetailRow(AppText.upiId, details['pa'] ?? 'Unknown'),
                Divider(height: 24.h),
                if (details['am'] != null && details['am']!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppText.amount,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                        ),
                      ),
                      Text(
                        '₹${details['am']}',
                        style: AppTextStyles.h1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              Get.toNamed('/accountant/payment/confirm');
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1aa3df),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 24.sp,
                              width: 24.sp,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppText.useForPayment,
                                  style: AppTextStyles.buttonText.copyWith(
                                    fontSize: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool boldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        Text(
          value,
          style: boldValue
              ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)
              : AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

class ScannerAnimation extends StatefulWidget {
  const ScannerAnimation({super.key});

  @override
  State<ScannerAnimation> createState() => _ScannerAnimationState();
}

class _ScannerAnimationState extends State<ScannerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScannerPainter(_animation.value),
          child: Container(),
        );
      },
    );
  }
}

class ScannerPainter extends CustomPainter {
  final double position;

  ScannerPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final y = size.height * position;

    // Draw scanning line
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint..color = Colors.green,
    );

    // Draw gradient glow below line
    final gradientRect = Rect.fromLTWH(0, y, size.width, 50.h);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.green.withOpacity(0.3), Colors.transparent],
    );

    final glowPaint = Paint()..shader = gradient.createShader(gradientRect);
    canvas.drawRect(gradientRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerPainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
