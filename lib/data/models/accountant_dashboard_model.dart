/// Read the first non-null value among the given keys. Lets fromJson tolerate
/// both camelCase (what the legacy frontend-driven contract used) and
/// snake_case (FastAPI's default serialization), so a backend response in
/// either convention parses correctly.
dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    if (json.containsKey(k) && json[k] != null) return json[k];
  }
  return null;
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return const {};
}

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
    // Backend (FastAPI) returns a FLAT shape:
    //   { amount_out: number, pending_payments: int, opening_balance: number }
    // The frontend originally expected nested objects (accountOverview,
    // tasksSummary, todayTransactions). Parse both — prefer nested when
    // present, otherwise synthesize the same model from the flat fields.
    final nestedOverview = _pick(json, ['accountOverview', 'account_overview']);
    final nestedTasks = _pick(json, ['tasksSummary', 'tasks_summary']);
    final hasFlat = json.containsKey('opening_balance') ||
        json.containsKey('amount_out') ||
        json.containsKey('pending_payments');

    AccountOverview overview;
    if (nestedOverview != null) {
      overview = AccountOverview.fromJson(_asMap(nestedOverview));
    } else if (hasFlat) {
      final openingBalance =
          (_pick(json, ['opening_balance', 'openingBalance']) as num? ?? 0).toDouble();
      final amountOut =
          (_pick(json, ['amount_out', 'amountOut']) as num? ?? 0).toDouble();
      final closing = openingBalance - amountOut;
      overview = AccountOverview(
        inHandCash: closing,
        inHandCashGrowth: '',
        openBalance: openingBalance,
        closingBalance: closing,
      );
    } else {
      overview = AccountOverview.fromJson(const {});
    }

    TasksSummary tasks;
    if (nestedTasks != null) {
      tasks = TasksSummary.fromJson(_asMap(nestedTasks));
    } else if (hasFlat) {
      tasks = TasksSummary(
        pendingPaymentsCount:
            (_pick(json, ['pending_payments', 'pendingPayments']) as num? ?? 0).toInt(),
      );
    } else {
      tasks = TasksSummary.fromJson(const {});
    }

    return AccountantDashboardModel(
      user: UserShort.fromJson(_asMap(_pick(json, ['user']))),
      accountOverview: overview,
      tasksSummary: tasks,
      todayTransactions:
          ((_pick(json, ['todayTransactions', 'today_transactions', 'transactions'])
                      as List?) ??
                  const [])
              .map((item) => TodayTransaction.fromJson(_asMap(item)))
              .toList(),
    );
  }
}

class UserShort {
  final String shortName;
  UserShort({required this.shortName});
  factory UserShort.fromJson(Map<String, dynamic> json) {
    final raw = _pick(json, ['shortName', 'short_name', 'firstName', 'first_name', 'name']);
    return UserShort(shortName: raw?.toString() ?? '');
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
      inHandCash: (_pick(json, ['inHandCash', 'in_hand_cash']) as num? ?? 0).toDouble(),
      inHandCashGrowth:
          _pick(json, ['inHandCashGrowth', 'in_hand_cash_growth'])?.toString() ?? '',
      openBalance:
          (_pick(json, ['openBalance', 'open_balance', 'opening_balance']) as num? ?? 0)
              .toDouble(),
      closingBalance:
          (_pick(json, ['closingBalance', 'closing_balance']) as num? ?? 0).toDouble(),
    );
  }
}

class TasksSummary {
  final int pendingPaymentsCount;
  TasksSummary({required this.pendingPaymentsCount});
  factory TasksSummary.fromJson(Map<String, dynamic> json) {
    return TasksSummary(
      pendingPaymentsCount:
          (_pick(json, ['pendingPaymentsCount', 'pending_payments_count']) as num? ?? 0)
              .toInt(),
    );
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
      id: _pick(json, ['id'])?.toString() ?? '',
      title: _pick(json, ['title', 'category'])?.toString() ?? '',
      subtitle: _pick(json, ['subtitle'])?.toString() ?? '',
      vendorName: _pick(json, ['vendorName', 'vendor_name', 'vendor'])?.toString() ?? '',
      timestamp: DateTime.tryParse(
              _pick(json, ['timestamp', 'created_at', 'createdAt'])?.toString() ?? '') ??
          DateTime.now(),
      amount: (_pick(json, ['amount']) as num? ?? 0).toDouble(),
      iconType: _pick(json, ['iconType', 'icon_type'])?.toString() ?? '',
    );
  }
}
