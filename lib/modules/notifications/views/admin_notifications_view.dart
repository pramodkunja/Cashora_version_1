import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../controllers/admin_notifications_controller.dart';
import '../data/notification_model.dart';

class AdminNotificationView extends GetView<AdminNotificationsController> {
  const AdminNotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AdminNotificationsController());

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
                'Mark as read',
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('All'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('New Requests ❹'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Clarifications'),
                ),
              ),
            ],
          ),
        ),
        body: Obx(
          () => TabBarView(
            children: [
              _buildList(context, controller.allNotifications),
              _buildList(context, controller.newRequests),
              _buildList(context, controller.clarifications),
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _buildUserRequestItem(context, items[index]),
    );
  }

  Widget _buildUserRequestItem(BuildContext context, NotificationItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: item.image != null
                    ? NetworkImage(item.image!)
                    : null,
                backgroundColor: Colors.grey[300],
                child: item.image == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              if (item.isUnread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.body ?? '',
                              style: AppTextStyles.h3.copyWith(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.isUrgent)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'URGENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ),
                          if (item.badgeText != null)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: item.badgeBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.badgeText!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: item.badgeColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (item.amount != null) ...[
                      SizedBox(width: 8),
                      Text(
                        item.amount!,
                        style: AppTextStyles.h3.copyWith(fontSize: 16),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTextStyles.bodyMedium.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(item.icon, size: 14, color: AppColors.textSlate),
                      const SizedBox(width: 4),
                    ] else ...[
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textSlate,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '${item.time} • ${item.ref ?? ""}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
