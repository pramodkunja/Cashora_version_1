import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text.dart';
import '../../../../utils/app_text_styles.dart';
import '../../controllers/accountant_analytics_controller.dart';

class FinancialReportsView extends GetView<AccountantAnalyticsController> {
  const FinancialReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppText.financialReports, style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Theme.of(context).iconTheme.color),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Report Parameters Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        color: AppColors.primaryBlue,
                      ), // Mock icon
                      const SizedBox(width: 8),
                      Text(AppText.reportParameters, style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date Range
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.startDate,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSlate,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDateBox(context, '10/01/2023'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.endDate,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSlate,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDateBox(context, '10/31/2023'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Category Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppText.category.toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSlate,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'All Categories',
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items:
                                ['All Categories', 'Office Supplies', 'Travel']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {},
                            dropdownColor: Theme.of(context).cardColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.generatePreview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppText.generatePreview,
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Preview Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppText.previewSummary, style: AppTextStyles.h3),
                Text(
                  'Oct 2023',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSlate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildTableHeader(),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  _buildTableRow('Oct 24', 'Office Supplies', '\$120.50'),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  _buildTableRow('Oct 23', 'Client Lunch', '\$85.00'),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  _buildTableRow('Oct 21', 'Uber Ride', '\$42.25'),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  _buildTableRow('Oct 18', 'Software Sub...', '\$299.00'),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppText.totalExpenses,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSlate,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          '\$546.75',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Export Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.exportCsv, // Success Snackbar
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.table_chart_outlined,
                          color: AppColors.textSlate,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppText.exportCsv,
                          style: AppTextStyles.buttonText.copyWith(
                            color: AppColors.textSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.exportPdf, // Success Snackbar
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppText.exportPdf,
                          style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(BuildContext context, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: AppTextStyles.bodyMedium),
          Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              AppText.date.toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSlate,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              AppText.category.toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSlate,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            AppText.amount.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSlate,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String date, String category, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              date,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSlate,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(category, style: AppTextStyles.bodyMedium),
          ),
          Text(
            amount,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
