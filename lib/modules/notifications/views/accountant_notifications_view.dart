import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../controllers/accountant_notifications_controller.dart';
import '../data/notification_model.dart';

class AccountantNotificationView
    extends GetView<AccountantNotificationsController> {
  const AccountantNotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AccountantNotificationsController());

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
                  child: Text('Action Required'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Updates'),
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
              _buildList(context, controller.updates),
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
        if (item.title == '3 Pending Payments') {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildAttentionCard(context, item),
          );
        } else if (item.title.contains('AWS Invoice')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildInvoiceCard(context, item),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildItem(context, item: item),
        );
      },
    );
  }

  Widget _buildAttentionCard(BuildContext context, NotificationItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warningOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ATTENTION NEEDED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warningOrange,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.title, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTextStyles.bodyMedium.color,
                    ),
                    children: [
                      const TextSpan(text: 'Totaling '),
                      TextSpan(
                        text: item.amount ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTextStyles.h3.color,
                        ),
                      ),
                      const TextSpan(text: ' require approval.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // AppColors.primary
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Review All'),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 80,
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.insert_chart, size: 40, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, NotificationItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF232F3E), // AWS Blue-ish
                child: const Text(
                  'aws',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  Icons.warning,
                  size: 14,
                  color: AppColors.warningOrange,
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
                    Text(
                      item.title,
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Pay Now',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2), // Adjusted alignment
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warningOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.amount ?? '',
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, {required NotificationItem item}) {
    // Logic to select icon/image
    Widget imageWidget;
    if (item.image != null) {
      imageWidget = CircleAvatar(
        backgroundImage: NetworkImage(item.image!),
        radius: 24,
      );
    } else if (item.title.startsWith('Uber')) {
      imageWidget = const CircleAvatar(
        backgroundColor: Colors.black,
        radius: 24,
        child: Text(
          'U',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      imageWidget = CircleAvatar(
        backgroundColor: item.iconBg ?? Colors.grey[200],
        radius: 24,
        child: Icon(
          item.icon ?? Icons.notifications,
          color: item.iconColor ?? Colors.grey,
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
          Stack(
            children: [
              imageWidget,
              if (item.ref == 'PAID')
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.successGreen,
                      size: 16,
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
                    Text(
                      item.title,
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    if (item.ref == 'REVIEW')
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text(
                          'REVIEW',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      )
                    else if (item.time.contains('ago'))
                      Text(item.time, style: AppTextStyles.bodySmall)
                    else if (item.title.startsWith('Uber'))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.amount ?? '',
                            style: AppTextStyles.h3.copyWith(fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            color: const Color(0xFFDCFCE7),
                            child: const Text(
                              'PAID',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (item.ref != null && item.amount != null)
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                  ],
                ),
                Text(
                  item.time.contains('ago')
                      ? (item.body ?? item.ref ?? '')
                      : item.time,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTextStyles.bodyMedium.color,
                  ),
                ),
                if (item.amount != null &&
                    item.title != 'Uber for Business') ...[
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTextStyles.bodyMedium.color,
                      ),
                      children: [
                        TextSpan(
                          text: item.amount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTextStyles.h3.color,
                          ),
                        ),
                        if (item.ref != null)
                          TextSpan(
                            text: ' • ${item.ref}',
                            style: TextStyle(color: AppColors.textSlate),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
