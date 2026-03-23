import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cash/utils/app_colors.dart';
import 'package:cash/utils/app_text.dart';
import 'package:cash/utils/app_text_styles.dart';
import 'package:cash/modules/accountant/controllers/completed_request_details_controller.dart';

class CompletedRequestDetailsView extends StatelessWidget {
  const CompletedRequestDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller on the fly
    final controller = Get.put(
      CompletedRequestDetailsController(),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Obx(() {
          final id = controller.paymentDetails['id'] ?? controller.paymentDetails['request_id'] ?? '---';
          return Text(
            'Payment #$id',
            style: AppTextStyles.h3.copyWith(color: Colors.black),
          );
        }),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final payment = controller.paymentDetails;
        if (payment.isEmpty) {
          return const Center(child: Text("No details available"));
        }

        // Parsing Data
        final amount = double.tryParse(payment['amount']?.toString() ?? '0')
                ?.toStringAsFixed(2) ??
            '0.00';
        final requestDate = _formatDate(payment['created_at']?.toString() ?? '');
        final paymentDate = _formatDate(payment['created_at']?.toString() ?? '');

        final requestorMap = payment['requestor'] as Map<String, dynamic>?;
        final requestorName = requestorMap != null 
            ? '${requestorMap['first_name'] ?? ''} ${requestorMap['last_name'] ?? ''}'.trim() 
            : 'Unknown';

        final department = payment['department'] ?? '---';
        final purpose = payment['purpose'] ?? '---';
        final description = payment['description'] ?? '---';
        
        final categoryMap = {
          'office_supplies': 'Office Supplies',
          'travel': 'Travel',
          'meals': 'Meals',
          'software': 'Software',
          'hardware': 'Hardware',
        };
        final categoryKey = payment['category'] ?? '';
        final category = categoryMap[categoryKey] ?? categoryKey.toString().replaceAll('_', ' ').capitalizeFirst ?? '---';
        
        final referenceCode = payment['request_id'] ?? '---';

        final paymentMethod = (payment['payment_method'] ?? 'UPI').toString().toUpperCase();
        final transactionId = payment['transaction_reference'] ?? '---'; // UTR
        final status = payment['status'] ?? 'paid';
        final processedAt = _formatTime(payment['created_at']?.toString() ?? '');

        final auditTrail = payment['audit_trail'] as List? ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status.toString().toUpperCase(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF16A34A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppText.totalPaidAmount,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('₹$amount', style: AppTextStyles.h1),
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey[100]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDateColumn(AppText.requestDate, requestDate),
                        Container(height: 40, width: 1, color: Colors.grey[200]),
                        _buildDateColumn(AppText.paymentDateLabel, paymentDate),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Request Info
              _buildSectionHeader(AppText.requestInformation, Icons.description),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(AppText.requestor, requestorName, boldValue: true),
                    Divider(color: Colors.grey[100], height: 32),
                    _buildInfoRow(AppText.department, department, boldValue: true),
                    Divider(color: Colors.grey[100], height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.purpose, // "Purpose" label
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSlate,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          purpose,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppText.description, // "Description" label
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSlate,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey[100], height: 32),
                     _buildInfoRow(AppText.category, category, boldValue: true),
                    Divider(color: Colors.grey[100], height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppText.referenceCode,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSlate,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            referenceCode,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Details
              _buildSectionHeader(
                AppText.paymentDetails,
                Icons.payments_outlined,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.paymentSource,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSlate,
                              ),
                            ),
                            Text(
                              paymentMethod,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey[100]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSimpleColumn("UTR / Txn ID", transactionId),
                        _buildSimpleColumn('Processed At', processedAt),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Audit Trail
              _buildSectionHeader(AppText.auditTrail, Icons.history),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: auditTrail.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isLast = index == auditTrail.length - 1;
                    
                    final label = item['label'] ?? '';
                    final actor = item['actor'] ?? '';
                    final role = item['actor_role'] ?? '';
                    final note = item['note'];
                    // Format timestamp if present, else just show label
                    // We don't have exact timestamp in sample for all, assuming string
                    final timestamp = item['timestamp']?.toString() ?? '';

                    return _buildTimelineItem(
                      title: label,
                      subtitle: "$actor ($role)${note != null ? '\n$note' : ''}",
                      date: timestamp,
                      icon: _getIconForLabel(label),
                      iconBg: _getIconBgForLabel(label),
                      iconColor: _getIconColorForLabel(label),
                      isLast: isLast,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '---';
    try {
      final dt = DateTime.parse(dateStr);
      final List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String dateStr) {
    if (dateStr.isEmpty) return '---';
    try {
      final dt = DateTime.parse(dateStr);
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return "$hour:$minute $amPm";
    } catch (_) {
      return dateStr;
    }
  }

  IconData _getIconForLabel(String label) {
    if (label.contains('Paid')) return Icons.payments;
    if (label.contains('Approved')) return Icons.check;
    if (label.contains('Submitted')) return Icons.send;
    return Icons.circle;
  }

  Color _getIconBgForLabel(String label) {
    if (label.contains('Paid')) return const Color(0xFFDCFCE7);
    if (label.contains('Approved')) return const Color(0xFFDBEAFE);
    if (label.contains('Submitted')) return const Color(0xFFF1F5F9);
    return Colors.grey[200]!;
  }

  Color _getIconColorForLabel(String label) {
    if (label.contains('Paid')) return const Color(0xFF16A34A);
    if (label.contains('Approved')) return AppColors.primaryBlue;
    if (label.contains('Submitted')) return AppColors.textSlate;
    return Colors.grey;
  }

  Widget _buildDateColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSlate),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool boldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSlate),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: boldValue
                ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSlate),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: Colors.grey[200])),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSlate,
                      height: 1.4,
                    ),
                  ),
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSlate.withOpacity(0.7),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
