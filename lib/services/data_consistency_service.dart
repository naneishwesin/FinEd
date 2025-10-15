// lib/services/data_consistency_service.dart
import 'package:flutter/material.dart';

import 'database_service.dart';

class DataConsistencyService {
  final DatabaseService _dbService = DatabaseService();
  static final DataConsistencyService _instance =
      DataConsistencyService._internal();
  factory DataConsistencyService() => _instance;
  DataConsistencyService._internal();

  // Cache for frequently accessed data
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get cached data or fetch from database
  Future<T> getCachedData<T>(
    String key,
    Future<T> Function() fetchFunction,
  ) async {
    // Check if data is cached and not expired
    if (_cache.containsKey(key) && _cacheTimestamps.containsKey(key)) {
      final timestamp = _cacheTimestamps[key]!;
      if (DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _cache[key] as T;
      }
    }

    // Fetch fresh data
    final data = await fetchFunction();
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    return data;
  }

  /// Clear specific cache entry
  void clearCache(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// Clear all cache
  void clearAllCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Invalidate cache for related data when transactions change
  Future<void> invalidateTransactionCache() async {
    clearCache('transactions');
    clearCache('weekly_transactions');
    clearCache('monthly_transactions');
    clearCache('current_balance');
    clearCache('budget_spent');
    clearCache('financial_health');
  }

  /// Invalidate cache for related data when balances change
  Future<void> invalidateBalanceCache() async {
    clearCache('current_balance');
    clearCache('emergency_balance');
    clearCache('investment_balance');
    clearCache('total_assets');
    clearCache('total_liabilities');
    clearCache('financial_health');
  }

  /// Invalidate cache for related data when budgets change
  Future<void> invalidateBudgetCache() async {
    clearCache('budgets');
    clearCache('budget_spent');
    clearCache('budget_status');
    clearCache('financial_health');
  }

  /// Ensure data consistency across all pages
  Future<void> ensureDataConsistency() async {
    try {
      // 1. Recalculate all balances
      await _dbService.recalculateAllBalances();

      // 2. Update budget spent amounts
      await _updateBudgetSpentAmounts();

      // 3. Validate data integrity
      await _validateDataIntegrity();

      // 4. Clear all caches to force fresh data
      clearAllCache();

      print('Data consistency check completed successfully');
    } catch (e) {
      print('Error ensuring data consistency: $e');
      rethrow;
    }
  }

  /// Update budget spent amounts based on actual transactions
  Future<void> _updateBudgetSpentAmounts() async {
    final budgets = await _dbService.getAllBudgets();

    for (final budget in budgets) {
      final type = budget['type'] as String;
      final spent = await _calculateBudgetSpent(type);
      await _dbService.updateBudgetSpent(type, spent);
    }
  }

  /// Calculate actual spent amount for a budget type
  Future<double> _calculateBudgetSpent(String budgetType) async {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (budgetType.toLowerCase()) {
      case 'weekly':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(Duration(days: 6));
        break;
      case 'monthly':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'yearly':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
      default:
        return 0.0;
    }

    final transactions = await _dbService.getTransactionsByDateRange(
      startDate,
      endDate,
    );

    return transactions
        .where((t) => t['type'] == 'expense')
        .fold<double>(0.0, (sum, t) => sum + (t['amount'] as num).toDouble().abs());
  }

  /// Validate data integrity across all tables
  Future<void> _validateDataIntegrity() async {
    final issues = <String>[];

    // Check for orphaned transactions
    final transactions = await _dbService.getAllTransactions();
    for (final transaction in transactions) {
      final category = transaction['category'] as String?;
      if (category != null) {
        final categories = await _dbService.getCategoriesByType(
          transaction['type'] as String,
        );
        if (!categories.any((c) => c['name'] == category)) {
          issues.add('Transaction with invalid category: $category');
        }
      }
    }

    // Check for negative balances
    final currentBalance = await _dbService.getCurrentBalance();
    if (currentBalance < 0) {
      issues.add('Current balance is negative: $currentBalance');
    }

    // Check for invalid budget amounts
    final budgets = await _dbService.getAllBudgets();
    for (final budget in budgets) {
      final amount = budget['amount'] as double? ?? 0;
      final spent = budget['spent'] as double? ?? 0;
      if (amount < 0) {
        issues.add('Budget amount is negative: ${budget['type']}');
      }
      if (spent < 0) {
        issues.add('Budget spent is negative: ${budget['type']}');
      }
    }

    if (issues.isNotEmpty) {
      print('Data integrity issues found:');
      for (final issue in issues) {
        print('  - $issue');
      }
    }
  }

  /// Get consistent transaction data across pages
  Future<List<Map<String, dynamic>>> getConsistentTransactions() async {
    return getCachedData('transactions', () => _dbService.getAllTransactions());
  }

  /// Get consistent weekly transactions
  Future<List<Map<String, dynamic>>> getConsistentWeeklyTransactions() async {
    return getCachedData('weekly_transactions', () => _getWeeklyTransactions());
  }

  /// Get consistent monthly transactions
  Future<List<Map<String, dynamic>>> getConsistentMonthlyTransactions() async {
    return getCachedData(
      'monthly_transactions',
      () => _getMonthlyTransactions(),
    );
  }

  /// Get consistent balance data
  Future<Map<String, double>> getConsistentBalances() async {
    return getCachedData(
      'balances',
      () async => {
        'current': await _dbService.getCurrentBalance(),
        'emergency': await _dbService.getEmergencyBalance(),
        'investment': await _dbService.getInvestmentBalance(),
      },
    );
  }

  /// Get consistent budget data
  Future<List<Map<String, dynamic>>> getConsistentBudgets() async {
    return getCachedData('budgets', () => _dbService.getAllBudgets());
  }

  /// Get consistent financial health data
  Future<Map<String, dynamic>> getConsistentFinancialHealth() async {
    return getCachedData(
      'financial_health',
      () async => {
        'current_balance': await _dbService.getCurrentBalance(),
        'emergency_balance': await _dbService.getEmergencyBalance(),
        'investment_balance': await _dbService.getInvestmentBalance(),
        'total_assets': await _dbService.getTotalAssets(),
        'total_liabilities': await _dbService.getTotalLiabilities(),
        'monthly_income': await _getMonthlyIncome(),
        'monthly_expenses': await _getMonthlyExpenses(),
      },
    );
  }

  /// Get weekly transactions for current week
  Future<List<Map<String, dynamic>>> _getWeeklyTransactions() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    return _dbService.getTransactionsByDateRange(
      startOfWeek,
      endOfWeek,
    );
  }

  /// Get monthly transactions for current month
  Future<List<Map<String, dynamic>>> _getMonthlyTransactions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _dbService.getTransactionsByDateRange(
      startOfMonth,
      endOfMonth,
    );
  }

  /// Get monthly income
  Future<double> _getMonthlyIncome() async {
    final transactions = await _getMonthlyTransactions();
    return transactions
        .where((t) => t['type'] == 'income')
        .fold<double>(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
  }

  /// Get monthly expenses
  Future<double> _getMonthlyExpenses() async {
    final transactions = await _getMonthlyTransactions();
    return transactions
        .where((t) => t['type'] == 'expense')
        .fold<double>(0.0, (sum, t) => sum + (t['amount'] as num).toDouble().abs());
  }

  /// Refresh data for a specific page
  Future<void> refreshPageData(String pageName) async {
    switch (pageName.toLowerCase()) {
      case 'home':
        await invalidateTransactionCache();
        await invalidateBalanceCache();
        break;
      case 'bills':
        await invalidateTransactionCache();
        break;
      case 'assets':
        await invalidateBalanceCache();
        break;
      case 'budget':
        await invalidateBudgetCache();
        break;
      case 'settings':
        clearAllCache();
        break;
      default:
        clearAllCache();
    }
  }

  /// Show data consistency status
  void showConsistencyStatus(BuildContext context) {
    final cacheSize = _cache.length;
    final cacheAge = _cacheTimestamps.isNotEmpty
        ? DateTime.now().difference(_cacheTimestamps.values.first).inMinutes
        : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Data Consistency Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cache entries: $cacheSize'),
            Text('Cache age: $cacheAge minutes'),
            Text('Cache expiry: ${_cacheExpiry.inMinutes} minutes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearAllCache();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Cache cleared')));
            },
            child: Text('Clear Cache'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
