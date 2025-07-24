import '../services/transaction_entry_service.dart';
import '../models/api/transaction_entry.dart';

class DashboardStats {
  final int totalTransactions;
  final int todayTransactions;
  final int totalQuantity;

  DashboardStats({
    required this.totalTransactions,
    required this.todayTransactions,
    required this.totalQuantity,
  });
}

class DashboardStatsService {
  final _svc = TransactionEntryService();

  Future<DashboardStats> fetchStats() async {
    final entries = await _svc.fetchTransactionEntries();
    final now = DateTime.now();

    final total = entries.length;
    final today = entries.where((e) =>
      e.transactionDate.year == now.year &&
      e.transactionDate.month == now.month &&
      e.transactionDate.day == now.day
    ).length;

    final quantity = entries.fold(0, (sum, e) => sum + e.quantity);

    return DashboardStats(
      totalTransactions: total,
      todayTransactions: today,
      totalQuantity: quantity,
    );
  }

  Future<int> fetchTransactionCount(String period) async {
    final entries = await TransactionEntryService().fetchTransactionEntries();
    final now = DateTime.now();

    return entries.where((e) {
      final d = e.transactionDate;
      return switch (period) {
        'daily' => d.year == now.year && d.month == now.month && d.day == now.day,
        'monthly' => d.year == now.year && d.month == now.month,
        'yearly' => d.year == now.year,
        _ => false
      };
    }).length;
  }

}
