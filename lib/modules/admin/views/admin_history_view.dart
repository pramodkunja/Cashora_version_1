import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/widgets/app_loader.dart';
import '../../../../utils/widgets/skeletons/skeleton_loader.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/admin_history_controller.dart';
import '../controllers/admin_approvals_controller.dart';
import 'widgets/admin_bottom_bar.dart';

class AdminHistoryView extends GetView<AdminHistoryController> {
  const AdminHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Hidden as per bottom nav usually
        leading: Padding(padding: const EdgeInsets.all(8.0)),
        title: Text(AppText.navHistory, style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppText.pastApprovalsTitle,
                    style: AppTextStyles.h1.copyWith(fontSize: 28),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Obx(
                  () => Row(
                    children: [
                      _buildFilterChip(
                        context,
                        AppText.filterAll,
                        controller.selectedFilter.value == 'All',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        AppText.filterPending,
                        controller.selectedFilter.value == 'Pending',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        AppText.filterApproved,
                        controller.selectedFilter.value == 'Approved',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        AppText.filterRejected,
                        controller.selectedFilter.value == 'Rejected',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        AppText.clarified,
                        controller.selectedFilter.value == 'Clarified',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const SkeletonListView();
                  }

                  if (controller.filteredRequests.isEmpty) {
                    return Center(
                      child: Text(
                        AppText.noRequests,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSlate,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.filteredRequests.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = controller.filteredRequests[index];
                      return GestureDetector(
                        onTap: () => controller.viewDetails(item),
                        child: _buildHistoryCard(context, item),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.updateFilter(
        label == AppText.filterAll
            ? 'All'
            : label == AppText.filterApproved
            ? 'Approved'
            : label == AppText.filterRejected
            ? 'Rejected'
            : label == AppText.filterPending
            ? 'Pending'
            : 'Clarified',
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppTextStyles.bodyMedium.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> item) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;
    String status = item['status']?.toString() ?? 'unknown';
    String statusText = status;

    if (status == 'approved' ||
        status == 'auto_approved' ||
        status == AppText.statusApproved) {
      statusColor = const Color(0xFF10B981); // Green
      statusBg = const Color(0xFFD1FAE5);
      statusIcon = Icons.check_circle_rounded;
      statusText = AppText.approvedSC;
    } else if (status == 'rejected' || status == AppText.statusRejected) {
      statusColor = const Color(0xFFEF4444); // Red
      statusBg = const Color(0xFFFEE2E2);
      statusIcon = Icons.cancel;
      statusText = AppText.statusRejected.toUpperCase();
    } else {
      // Clarification
      statusColor = const Color(0xFFF59E0B); // Amber
      statusBg = const Color(0xFFFEF3C7);
      statusIcon = Icons.help_rounded;
      statusText = AppText.clarification.toUpperCase();
    }

    // Data Extraction Helpers
    String requestId =
        item['request_id']?.toString() ?? item['id']?.toString() ?? 'N/A';
    String actionDate = _formatDate(item['updated_at'] ?? item['created_at']);
    String amount = item['amount']?.toString() ?? '0.00';

    String userName = 'Unknown';
    String userInitials = '??';

    if (item['requestor'] != null && item['requestor'] is Map) {
      final r = item['requestor'];
      userName = "${r['first_name'] ?? ''} ${r['last_name'] ?? ''}".trim();
      if (userName.isEmpty) userName = r['email']?.toString() ?? 'Unknown';
    } else if (item['user'] != null) {
      userName = item['user'].toString();
    }

    if (userName.isNotEmpty) {
      final parts = userName.trim().split(' ');
      if (parts.length > 1) {
        userInitials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
      } else {
        userInitials = parts[0][0].toUpperCase();
      }
    }

    String title =
        item['purpose']?.toString() ??
        item['title']?.toString() ??
        'Expense Request';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REQUEST ID',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    requestId,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTextStyles.h3.color,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ACTION DATE',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    actionDate,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTextStyles.h3.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(thickness: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getAvatarColor(userInitials),
                radius: 20,
                child: Text(
                  userInitials,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _getAvatarTextColor(userInitials),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSlate,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text('₹$amount', style: AppTextStyles.h3.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSlate,
                size: 20,
              ),
            ],
          ),
          if (statusText == AppText.clarification.toUpperCase()) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Colors.black26
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Get.isDarkMode
                      ? Colors.white10
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.mark_email_read_rounded,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Response Received",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTextStyles.h3.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "User has replied to your query. Review next steps.",
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr.split('T').first;
    }
  }

  Color _getAvatarColor(String initials) {
    final int hash = initials.codeUnits.fold(0, (p, c) => p + c);
    // Simple mock random color logic
    if (hash % 3 == 0) return const Color(0xFFDBEAFE); // Blue
    if (hash % 3 == 1) return const Color(0xFFF3E8FF); // Purple
    return const Color(0xFFFEF3C7); // Amber
  }

  Color _getAvatarTextColor(String initials) {
    final int hash = initials.codeUnits.fold(0, (p, c) => p + c);
    if (hash % 3 == 0) return const Color(0xFF1D4ED8); // Blue
    if (hash % 3 == 1) return const Color(0xFF7E22CE); // Purple
    return const Color(0xFFB45309); // Amber
  }
}
