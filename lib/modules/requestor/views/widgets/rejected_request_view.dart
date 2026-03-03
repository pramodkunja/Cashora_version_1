import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Needed for AttachmentCard helpers internally handled or passed
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../utils/widgets/attachment_card.dart';

class RejectedRequestView extends StatelessWidget {
  final Map<String, dynamic> request;

  const RejectedRequestView({Key? key, required this.request})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amount = (request['amount'] as double? ?? 0.0).toStringAsFixed(2);
    final rejectionReason =
        request['rejection_reason'] ??
        request['admin_remarks'] ??
        "No reason provided.";
    final String dateStr =
        request['updated_at']?.toString() ??
        request['date']?.toString() ??
        DateTime.now().toString();
    final String rejectionDate = _formatDate(dateStr);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Request Details',
          style: AppTextStyles.h3.copyWith(color: AppColors.textDark),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.textDark,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Red Header
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2), // Red 100
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block,
                color: Color(0xFFEF4444),
                size: 32,
              ), // Red 500
            ),
            const SizedBox(height: 16),
            Text("₹$amount", style: AppTextStyles.h1.copyWith(fontSize: 40)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2), // Red 100
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "REJECTED",
                style: TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 2. Reason Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2), // Red 50
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFECACA)), // Red 200
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFECACA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.comment,
                          size: 14,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "REASON FOR REJECTION",
                        style: TextStyle(
                          color: Color(0xFF7F1D1D),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"$rejectionReason"',
                    style: TextStyle(
                      color: const Color(0xFF7F1D1D),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Note from Approver • $rejectionDate",
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Information",
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey[100]),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    "Request ID",
                    "#${request['request_id'] ?? 'REQ-000'}",
                  ),
                  _buildInfoRow(
                    "Requestor",
                    request['employee_name'] ??
                        request['created_by_name'] ??
                        'You',
                  ),
                  _buildInfoRow(
                    "Department",
                    request['department'] ?? 'General',
                  ),
                  _buildInfoRow(
                    "Submission Date",
                    _formatDate(request['created_at'] ?? ''),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Purpose",
                    style: TextStyle(color: AppColors.textSlate, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request['title'] ?? request['purpose'] ?? 'No purpose',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. History Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "History",
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey[100]),
                  const SizedBox(height: 24),
                  _buildHistoryItem(
                    icon: Icons.send,
                    iconColor: Colors.white,
                    iconBg: AppColors.primaryBlue,
                    title: "Submitted",
                    date: _formatDate(request['created_at']),
                    isLast: false,
                  ),
                  _buildHistoryItem(
                    icon: Icons.close,
                    iconColor: Colors.white,
                    iconBg: const Color(0xFFEF4444),
                    title: "Rejected",
                    date: rejectionDate,
                    subText: "By Admin",
                    subTextColor: const Color(0xFFEF4444),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSlate, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String date,
    String? subText,
    Color? subTextColor,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[200],
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(color: AppColors.textSlate, fontSize: 12),
            ),
            if (subText != null) ...[
              const SizedBox(height: 4),
              Text(
                subText,
                style: TextStyle(
                  color: subTextColor ?? AppColors.textSlate,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Recently'; // Fallback
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return 'Recently';
    }
  }
}
