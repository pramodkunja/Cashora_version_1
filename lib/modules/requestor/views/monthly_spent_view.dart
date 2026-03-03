import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/common_search_bar.dart';
import '../controllers/monthly_spent_controller.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import 'dart:math';

class MonthlySpentView extends GetView<MonthlySpentController> {
  const MonthlySpentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MonthlySpentController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Month Selector App Bar (Pinned)
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF0F172A),
                ),
                onPressed: () => Get.back(),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: controller.previousMonth,
                  ),
                  GestureDetector(
                    onTap: controller.selectMonthYear,
                    child: Obx(
                      () => Text(
                        controller.currentMonth.value,
                        style: AppTextStyles.h3.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: controller.nextMonth,
                  ),
                ],
              ),
            ),

            // 2. Collapsing Total Spent Card
            SliverPersistentHeader(
              pinned: true,
              delegate: _TotalSpentHeaderDelegate(controller: controller),
            ),

            // 3. Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 4. Sticky Search & Filters
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchFilterHeaderDelegate(controller: controller),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 5. List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppText.monthlySpentTransactions,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 6. Transaction List
            Obx(() {
              if (controller.displayedTransactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "No transactions found",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = controller.displayedTransactions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: item['color'],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item['icon'], color: item['iconColor']),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: AppTextStyles.h3.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['date'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item['amount'].toString().replaceAll('\$', '₹'),
                                style: AppTextStyles.h3.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              _buildStatusBadge(item['status']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: controller.displayedTransactions.length),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    if (status == 'Paid') {
      bg = const Color(0xFFE0F2FE); // Blue
      text = const Color(0xFF0EA5E9);
    } else if (status == 'Pending') {
      bg = const Color(0xFFFFF7ED); // Orange
      text = const Color(0xFFEA580C);
    } else {
      bg = const Color(0xFFFEE2E2); // Red
      text = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: AppTextStyles.h3.copyWith(fontSize: 10, color: text),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    return Obx(() {
      final isSelected = controller.selectedFilterIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeFilter(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      );
    });
  }
}

class _TotalSpentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final MonthlySpentController controller;

  _TotalSpentHeaderDelegate({required this.controller});

  // Dimensions
  final double expandedHeight = 220.0;
  final double collapsedHeight = 90.0;
  final double horizontalMargin = 24.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calculate 0.0 -> 1.0 (Expanded -> Collapsed)
    final double percent = (shrinkOffset / (expandedHeight - collapsedHeight))
        .clamp(0.0, 1.0);
    final bool isCollapsed = percent > 0.6; // Switching point

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Container
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF0F9FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(
              32 * (1 - percent) + 16 * percent,
            ), // Animate radius
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFE0F2FE,
                ).withOpacity(0.5 + (0.2 * percent)),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),

        // Expanded Content (Fades Out)
        Positioned.fill(
          child: Opacity(
            // Use interval to fade out faster before space runs out
            opacity: (1 - (percent * 1.5)).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, -30 * percent),
              child: OverflowBox(
                minHeight: expandedHeight,
                maxHeight: expandedHeight,
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalMargin + 16,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppText.totalSpent,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          '₹${controller.totalSpent.value.toStringAsFixed(2)}',
                          style: AppTextStyles.h1.copyWith(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_down,
                              size: 16,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 4),
                            Obx(
                              () => Text(
                                controller.comparisonText.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Collapsed Content (Fades In)
        Positioned.fill(
          child: Opacity(
            // Fade in late
            opacity: ((percent - 0.7) * 3.3).clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: horizontalMargin + 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Pending",
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "₹120.00",
                        style: TextStyle(
                          color: const Color(0xFFEA580C),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Center / Main Info
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppText.totalSpent,
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '₹${controller.totalSpent.value.toStringAsFixed(2)}',
                          style: AppTextStyles.h3.copyWith(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  // Comparison Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_down,
                      size: 16,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _SearchFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final MonthlySpentController controller;

  _SearchFilterHeaderDelegate({required this.controller});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF8FAFC), // Match scaffold background
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CommonSearchBar(
              controller: controller.searchController,
              hintText: AppText.searchTransactions,
              onChanged: controller.searchTransactions,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildFilterChipWidget(0, AppText.filterAll),
                const SizedBox(width: 8),
                _buildFilterChipWidget(1, AppText.filterPaid),
                const SizedBox(width: 8),
                _buildFilterChipWidget(2, AppText.filterPending),
                const SizedBox(width: 8),
                _buildFilterChipWidget(3, AppText.filterRejected),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Duplicated helper for access within delegate
  Widget _buildFilterChipWidget(int index, String label) {
    return Obx(() {
      final isSelected = controller.selectedFilterIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeFilter(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      );
    });
  }

  @override
  double get maxExtent => 130.0;

  @override
  double get minExtent => 130.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
