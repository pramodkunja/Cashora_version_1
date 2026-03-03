import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/auth_service.dart';
import '../../controllers/create_request_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';
import '../../../../utils/widgets/app_loader.dart';

class ReviewRequestView extends GetView<CreateRequestController> {
  const ReviewRequestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppText.reviewRequest, style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                AppText.totalRequestedAmount,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTextStyles.bodyMedium.color,
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  '₹${controller.amount.value.toStringAsFixed(2)}',
                  style: AppTextStyles.h1.copyWith(fontSize: 40),
                ),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.requestDetails,
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 24),

                    _buildDetailItem(
                      icon: Icons.person,
                      title: "Requestor",
                      value:
                          Get.find<AuthService>().currentUser.value?.name ??
                          'Unknown',
                    ),
                    const SizedBox(height: 24),

                    Obx(
                      () => _buildDetailItem(
                        icon: Icons.receipt_long,
                        title: AppText.requestType,
                        value: controller.requestType.value,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      final cat = controller.selectedExpenseCategory.value;
                      return _buildDetailItem(
                        icon: cat?['icon'] ?? Icons.category,
                        title: AppText.category,
                        value: cat?['name'] ?? AppText.notSelected,
                        iconColorOverride: AppColors.primaryBlue,
                      );
                    }),
                    const SizedBox(height: 24),
                    Obx(
                      () => _buildDetailItem(
                        icon: Icons.label,
                        title: AppText.purpose,
                        value: controller.purpose.value,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => _buildDetailItem(
                        icon: Icons.description,
                        title: AppText.description,
                        value: controller.description.value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Attachments
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.attachments,
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final allFiles = <XFile>[];
                      // Add QR if present
                      if (controller.qrFile.value != null) {
                        // Ideally we might want to tag this visually, but for now just adding to list
                        allFiles.add(controller.qrFile.value!);
                      }
                      // Add Receipt if present
                      if (controller.receiptFile.value != null) {
                        allFiles.add(controller.receiptFile.value!);
                      }
                      // Add standard attachments (bills)
                      allFiles.addAll(controller.attachedFiles);

                      if (allFiles.isNotEmpty) {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allFiles.length,
                          separatorBuilder: (ctx, idx) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            XFile file = allFiles[index];
                            // Determine specific icon or label based on file identity?
                            // For now, uniform display.
                            bool isQr = file == controller.qrFile.value;
                            bool isReceipt =
                                file == controller.receiptFile.value;
                            String label = file.name;
                            IconData icon = Icons.image;
                            Color iconColor = AppColors.primaryBlue;

                            if (isQr) {
                              label = "QR Code";
                              icon = Icons.qr_code_2;
                              iconColor = Colors.purple;
                            } else if (isReceipt) {
                              label = "Receipt";
                              icon = Icons.receipt;
                              iconColor = Colors.green;
                            }

                            return GestureDetector(
                              onTap: () => _showImagePreview(context, file),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.infoBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(icon, color: iconColor),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            label,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (isQr || isReceipt)
                                            Text(
                                              file.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.visibility,
                                      size: 18,
                                      color: AppColors.textLight,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Text(
                          AppText.noAttachments,
                          style: const TextStyle(color: Colors.grey),
                        );
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: Obx(
                  () => PrimaryButton(
                    text: controller.isLoading.value
                        ? 'Submitting...'
                        : AppText.submitRequest,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submitRequest,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, XFile file) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).cardColor,
              ),
              clipBehavior: Clip.hardEdge,
              child: FutureBuilder<Uint8List>(
                future: file.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: AppSpinner()),
                    );
                  }
                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text("Error loading preview")),
                    );
                  }
                  if (snapshot.hasData) {
                    return Image.memory(snapshot.data!, fit: BoxFit.contain);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColorOverride,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFE0F2FE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColorOverride ?? const Color(0xFF0EA5E9),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTextStyles.bodyMedium.color,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: AppTextStyles.h3.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
