import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../controllers/requestor_notifications_controller.dart';
import '../data/notification_model.dart'; // Import model

class RequestorNotificationView
    extends GetView<RequestorNotificationsController> {
  const RequestorNotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(
      RequestorNotificationsController(),
    ); // Lazy put or direct put if not in pages

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTextStyles.h1.color),
            onPressed: () => Get.back(),
          ),
          title: Text('Notifications', style: AppTextStyles.h2),
          centerTitle: false,
          actions: [
            TextButton(
              onPressed: controller.markAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          bottom: TabBar(
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: AppTextStyles.bodyMedium.color,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.primary,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('All'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Action Required ❶'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Approved'),
                ),
              ),
            ],
          ),
        ),
        body: Obx(
          () => TabBarView(
            children: [
              _buildList(context, controller.allNotifications),
              _buildList(context, controller.actionRequired),
              _buildList(context, controller.approved),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<NotificationItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No notifications',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        // Custom rendering based on type or existing UI structure
        if (item.title == 'Clarification Needed') {
          return _buildClarificationCard(context, item);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildNotificationItem(
            context,
            icon: item.icon ?? Icons.notifications,
            iconBg: item.iconBg ?? (Colors.grey[200] ?? Colors.grey.shade200),
            iconColor: item.iconColor ?? Colors.grey,
            title: item.title,
            ref: item.ref,
            time: item.time,
            body: item.body,
            amount: item.amount,
          ),
        );
      },
    );
  }

  Widget _buildClarificationCard(BuildContext context, NotificationItem item) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: const Border(
              left: BorderSide(color: AppColors.warningOrange, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: AppColors.warningOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: AppTextStyles.h3.copyWith(fontSize: 16),
                            ),
                            Text(item.time, style: AppTextStyles.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (item.ref != null)
                          Text(item.ref!, style: AppTextStyles.bodySmall),
                        const SizedBox(height: 8),
                        Text(item.body ?? '', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.isUrgent)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    // Helper if needed for logic-based grouping
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: AppColors.textSlate,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? ref,
    required String time,
    String? body,
    String? amount,
  }) {
    // Handling RickText for payment if amount exists
    Widget? contentWidget;
    if (amount != null && body != null && body.contains('sent to')) {
      contentWidget = RichText(
        text: TextSpan(
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTextStyles.bodyMedium.color,
          ),
          children: [
            TextSpan(
              text: amount,
              style: AppTextStyles.h3.copyWith(fontSize: 14),
            ),
            TextSpan(text: ' $body'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                    Text(time, style: AppTextStyles.bodySmall),
                  ],
                ),
                if (ref != null) ...[
                  const SizedBox(height: 4),
                  Text(ref, style: AppTextStyles.bodySmall),
                ],
                const SizedBox(height: 8),
                if (contentWidget != null)
                  contentWidget
                else
                  Text(
                    body ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTextStyles.bodyMedium.color,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
