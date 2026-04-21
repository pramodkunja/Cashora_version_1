class AccountantDashboardModel {
  final UserShort user;
  final AccountOverview accountOverview;
  final TasksSummary tasksSummary;
  final List<TodayTransaction> todayTransactions;

  AccountantDashboardModel({
    required this.user,
    required this.accountOverview,
    required this.tasksSummary,
    required this.todayTransactions,
  });

  factory AccountantDashboardModel.fromJson(Map<String, dynamic> json) {
    return AccountantDashboardModel(
      user: UserShort.fromJson(json['user'] ?? {}),
      accountOverview: AccountOverview.fromJson(json['accountOverview'] ?? {}),
      tasksSummary: TasksSummary.fromJson(json['tasksSummary'] ?? {}),
      todayTransactions: (json['todayTransactions'] as List? ?? [])
          .map((item) => TodayTransaction.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class UserShort {
  final String shortName;
  UserShort({required this.shortName});
  factory UserShort.fromJson(Map<String, dynamic> json) {
    return UserShort(shortName: json['shortName']?.toString() ?? '');
  }
}

class AccountOverview {
  final double inHandCash;
  final String inHandCashGrowth;
  final double openBalance;
  final double closingBalance;

  AccountOverview({
    required this.inHandCash,
    required this.inHandCashGrowth,
    required this.openBalance,
    required this.closingBalance,
  });

  factory AccountOverview.fromJson(Map<String, dynamic> json) {
    return AccountOverview(
      inHandCash: (json['inHandCash'] ?? 0.0).toDouble(),
      inHandCashGrowth: json['inHandCashGrowth']?.toString() ?? '',
      openBalance: (json['openBalance'] ?? 0.0).toDouble(),
      closingBalance: (json['closingBalance'] ?? 0.0).toDouble(),
    );
  }
}

class TasksSummary {
  final int pendingPaymentsCount;
  TasksSummary({required this.pendingPaymentsCount});
  factory TasksSummary.fromJson(Map<String, dynamic> json) {
    return TasksSummary(pendingPaymentsCount: json['pendingPaymentsCount'] ?? 0);
  }
}

class TodayTransaction {
  final String id;
  final String title;
  final String subtitle;
  final String vendorName;
  final DateTime timestamp;
  final double amount;
  final String iconType;

  TodayTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.vendorName,
    required this.timestamp,
    required this.amount,
    required this.iconType,
  });

  factory TodayTransaction.fromJson(Map<String, dynamic> json) {
    return TodayTransaction(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      amount: (json['amount'] ?? 0.0).toDouble(),
      iconType: json['iconType']?.toString() ?? '',
    );
  }
}
