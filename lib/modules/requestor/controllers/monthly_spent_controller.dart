import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_date_picker_dialog.dart';

class MonthlySpentController extends GetxController {
  final currentMonth = 'October 2023'.obs;
  final selectedFilterIndex = 0.obs;
  final totalSpent = 1240.50.obs;
  final comparisonText = '12% less than Sept'.obs;

  final searchController = TextEditingController();

  final allTransactions = <Map<String, dynamic>>[
    {
      'title': 'Office Depot',
      'date': 'Oct 24, 2023',
      'amount': '₹45.00',
      'status': 'Paid',
      'icon': Icons.store,
      'color': const Color(0xFFE0F2FE), // Blue 50
      'iconColor': const Color(0xFF0EA5E9), // Sky 500
    },
    {
      'title': 'Starbucks',
      'date': 'Oct 22, 2023',
      'amount': '₹12.50',
      'status': 'Pending',
      'icon': Icons.local_cafe,
      'color': const Color(0xFFFFF7ED), // Orange 50
      'iconColor': const Color(0xFFEA580C), // Orange 600
    },
    {
      'title': 'Uber',
      'date': 'Oct 20, 2023',
      'amount': '₹28.00',
      'status': 'Paid',
      'icon': Icons.directions_car,
      'color': const Color(0xFFF3E8FF), // Purple 50
      'iconColor': const Color(0xFF9333EA), // Purple 600
    },
    {
      'title': 'Delta Airlines',
      'date': 'Oct 15, 2023',
      'amount': '₹450.00',
      'status': 'Rejected',
      'icon': Icons.flight,
      'color': const Color(0xFFFEE2E2), // Red 50
      'iconColor': const Color(0xFFDC2626), // Red 600
    },
    {
      'title': 'Client Dinner',
      'date': 'Oct 12, 2023',
      'amount': '₹120.00',
      'status': 'Paid',
      'icon': Icons.restaurant,
      'color': const Color(0xFFDCFCE7), // Green 50
      'iconColor': const Color(0xFF16A34A), // Green 600
    },
  ];

  // To simulate filtering
  final displayedTransactions = <Map<String, dynamic>>[].obs;

  // Search Query
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initial load
    _applyFilters();

    // Listen to search changes
    searchController.addListener(() {
      searchTransactions(searchController.text);
    });
  }

  void changeFilter(int index) {
    selectedFilterIndex.value = index;
    _applyFilters();
  }

  void searchTransactions(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var result = allTransactions;

    // 1. Filter by Status
    String statusFilter = '';
    switch (selectedFilterIndex.value) {
      case 1:
        statusFilter = 'Paid';
        break;
      case 2:
        statusFilter = 'Pending';
        break;
      case 3:
        statusFilter = 'Rejected';
        break;
      default:
        statusFilter = '';
        break;
    }

    if (statusFilter.isNotEmpty) {
      result = result.where((t) => t['status'] == statusFilter).toList();
    }

    // 2. Filter by Search Query
    if (searchQuery.value.isNotEmpty) {
      final lowerQuery = searchQuery.value.toLowerCase();
      result = result
          .where(
            (t) =>
                t['title'].toString().toLowerCase().contains(lowerQuery) ||
                t['amount'].toString().toLowerCase().contains(lowerQuery),
          )
          .toList();
    }

    displayedTransactions.assignAll(result);
  }

  void previousMonth() {
    _changeMonth(-1);
  }

  void nextMonth() {
    _changeMonth(1);
  }

  void _changeMonth(int offset) {
    // Parse
    final parts = currentMonth.value.split(' ');
    final monthName = parts[0];
    final year = int.parse(parts[1]);

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    int monthIndex = months.indexOf(monthName) + 1;

    // Calculate new date
    var newDate = DateTime(year, monthIndex + offset, 1);

    // Update string
    currentMonth.value = '${months[newDate.month - 1]} ${newDate.year}';

    // Refresh data would happen here
  }

  void selectMonthYear() {
    // Parse current selection for initial date
    // Format "October 2023"
    final parts = currentMonth.value.split(' ');
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    int monthIndex = months.indexOf(parts[0]) + 1;
    if (monthIndex == 0) monthIndex = 10; // Fallback
    int year = int.tryParse(parts[1]) ?? 2023;

    Get.dialog(
      CustomDatePickerDialog(
        initialDate: DateTime(year, monthIndex, 1),
        onDateSelected: (selectedDate) {
          // Format back to "October 2023"
          // We can also store the full selectedDate if we want to filter by specific day later
          String monthName = months[selectedDate.month - 1];
          currentMonth.value = '$monthName ${selectedDate.year}';

          // Optionally triggered logic to fetch data for that specific day or month
          // For now, updating text mimics the "Apply" behavior
        },
      ),
    );
  }
}
