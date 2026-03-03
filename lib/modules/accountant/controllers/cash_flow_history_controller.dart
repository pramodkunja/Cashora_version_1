import 'package:get/get.dart';

class CashFlowHistoryController extends GetxController {
  final selectedFilter = 0.obs; // 0: This Month, 1: Last 3 Months, 2: Custom

  void changeFilter(int index) {
    selectedFilter.value = index;
  }

  // TODO: Add logic to fetch actual history data
}
