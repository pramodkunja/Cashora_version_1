import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/create_request_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/buttons/primary_button.dart';

class RequestSuccessView extends GetView<CreateRequestController> {
  const RequestSuccessView({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final status = args['status'] as String? ?? 'pending';
    final paymentStatus = args['payment_status'] as String? ?? 'Pending';
    final amount = (args['amount'] as num?)?.toDouble() ?? 0.0;
    final requestId = args['request_id'] as String? ?? '';
    final categoryName = args['category'] as String? ?? 'General';

    // Extra details for View Details
    final purpose = args['purpose'] as String? ?? '';
    final description = args['description'] as String? ?? '';
    final date = args['date'] as String? ?? '';
    final attachments = args['attachments'] ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSlate),
            onPressed: () => Get.offAllNamed(AppRoutes.REQUESTOR),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: _buildDetailedSuccessUI(
            context,
            status,
            paymentStatus,
            amount,
            requestId,
            categoryName,
            purpose,
            description,
            date,
            attachments,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedSuccessUI(
    BuildContext context,
    String status,
    String paymentStatus,
    double amount,
    String requestId,
    String categoryName,
    String purpose,
    String description,
    String date,
    dynamic attachments,
  ) {
    final isApproved = status == 'auto_approved';
    final mainIcon = isApproved
        ? Icons.check_rounded
        : Icons.hourglass_top_rounded;
    final mainColor = isApproved
        ? AppColors.successGreen
        : AppColors.primaryBlue;
    final bgShapeColor = isApproved
        ? (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF064E3B)
              : const Color(0xFFE4F8F0))
        : (Theme.of(context).primaryColor.withOpacity(0.1));

    final title = isApproved
        ? AppText.requestApproved
        : AppText.requestSubmitted;
    final subtitle = isApproved
        ? AppText.fundsAdded
        : AppText.requestSubmittedDesc;

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: bgShapeColor,
            shape: BoxShape.circle,
          ),
          child: Icon(mainIcon, size: 40, color: mainColor),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.h1.copyWith(
            fontSize: 24,
            height: 1.2,
            color: AppTextStyles.h1.color,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTextStyles.bodyMedium.color,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),

        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    AppText.totalAmount,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 24),

                  _buildRowItem(
                    icon: Icons.inventory_2_outlined,
                    iconBg: Theme.of(context).primaryColor.withOpacity(0.1),
                    iconColor: AppColors.primaryBlue,
                    label: AppText.category,
                    value: categoryName,
                    context: context,
                  ),
                  const SizedBox(height: 20),
                  _buildRowItem(
                    icon: Icons.tag,
                    iconBg: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFF1F5F9),
                    iconColor:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        const Color(0xFF64748B),
                    label: AppText.requestId,
                    value: '#$requestId',
                    context: context,
                  ),
                  const SizedBox(height: 24),

                  // Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppText.status,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? AppColors.successGreen.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isApproved
                                ? AppColors.successGreen.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isApproved
                                  ? Icons.check
                                  : Icons.access_time_rounded,
                              size: 14,
                              color: isApproved
                                  ? AppColors.successGreen
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isApproved
                                  ? AppText.approvedSC
                                  : AppText.pendingSC,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isApproved
                                    ? AppColors.successGreen
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppText.paymentStatus,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).disabledColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              paymentStatus,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: AppText.goToDashboard,
            onPressed: () => Get.offAllNamed(AppRoutes.REQUESTOR),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Get.toNamed(
              AppRoutes.REQUEST_DETAILS_READ,
              arguments: {
                'title': purpose,
                'amount': amount,
                'status': status == 'auto_approved' ? 'Approved' : 'Pending',
                'category': categoryName,
                'date': date,
                'description': description,
                'attachments': attachments,
              },
            );
          },
          child: Text(
            AppText.viewDetails,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRowItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
