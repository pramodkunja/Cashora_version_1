import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text.dart';
import '../../utils/app_text_styles.dart';

class TimelineItemWidget extends StatelessWidget {
  final String question;
  final String response;
  final String askedAt;
  final String respondedAt;
  final String approverName;
  final bool isSystemEvent;
  final bool isSuccess;
  final bool isError;

  const TimelineItemWidget({
    Key? key,
    required this.question,
    required this.response,
    required this.askedAt,
    required this.respondedAt,
    required this.approverName,
    this.isSystemEvent = false,
    this.isSuccess = false,
    this.isError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSystemEvent) {
      Color dotColor = Colors.blue;
      Color cardBg = Colors.blue.shade50;
      Color cardBorder = Colors.blue.shade100;
      IconData icon = Icons.info;
      Color iconColor = Colors.blue;

      if (isSuccess) {
        dotColor = AppColors.successGreen;
        cardBg = const Color(0xFFECFDF5);
        cardBorder = const Color(0xFFA7F3D0);
        icon = Icons.check_circle;
        iconColor = AppColors.successGreen;
      } else if (isError) {
        dotColor = AppColors.error;
        cardBg = const Color(0xFFFEF2F2);
        cardBorder = const Color(0xFFFECACA);
        icon = Icons.cancel;
        iconColor = AppColors.error;
      } else {
        // Default System Event (Submitted)
        dotColor = Colors.grey;
        cardBg = Colors.grey.shade50;
        cardBorder = Colors.grey.shade200;
        icon = Icons.upload_file;
        iconColor = Colors.grey;
      }

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -31,
            top: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (response.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            response,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 12,
                              color: AppColors.textSlate,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  askedAt,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 10,
                    color: AppColors.textSlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Existing Chat UI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Admin Question Node
        if (question.isNotEmpty)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -31,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200] ?? Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 14,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          approverName,
                          style: AppTextStyles.h3.copyWith(fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          askedAt,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSlate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        // 2. My Response Node
        if (response.isNotEmpty)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -31,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981), // Green dot
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.face,
                            size: 14,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppText.you,
                          style: AppTextStyles.h3.copyWith(fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          respondedAt,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSlate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(response, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
