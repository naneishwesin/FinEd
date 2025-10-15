// lib/services/balance_calculation_service.dart
import 'package:flutter/foundation.dart';

import 'database_service.dart';

class BalanceCalculationService {
  static final BalanceCalculationService _instance =
      BalanceCalculationService._internal();
  factory BalanceCalculationService() => _instance;
  BalanceCalculationService._internal();

  final DatabaseService _databaseService = DatabaseService();

  // Calculate current balance from all transactions
  Future<double> calculateCurrentBalance() async {
    try {
      final transactions = await _databaseService.getAllTransactions();
      double balance = 0.0;

      for (final transaction in transactions) {
        final amount = transaction['amount'] as double? ?? 0.0;
        final type = transaction['type'] as String? ?? 'expense';

        if (type == 'income') {
          balance += amount;
        } else if (type == 'expense') {
          balance -= amount.abs(); // Ensure expense is negative
        }
      }

      debugPrint('Calculated current balance: $balance');
      return balance;
    } catch (e) {
      debugPrint('Error calculating current balance: $e');
      return 0.0;
    }
  }

  // Calculate emergency fund balance
  Future<double> calculateEmergencyBalance() async {
    try {
      final emergencyFunds = await _databaseService.getEmergencyFunds();
      double balance = 0.0;

      for (final fund in emergencyFunds) {
        final amount = fund['amount'] as double? ?? 0.0;
        balance += amount;
      }

      debugPrint('Calculated emergency balance: $balance');
      return balance;
    } catch (e) {
      debugPrint('Error calculating emergency balance: $e');
      return 0.0;
    }
  }

  // Calculate investment balance
  Future<double> calculateInvestmentBalance() async {
    try {
      final investments = await _databaseService.getInvestments();
      double balance = 0.0;

      for (final investment in investments) {
        final amount = investment['amount'] as double? ?? 0.0;
        balance += amount;
      }

      debugPrint('Calculated investment balance: $balance');
      return balance;
    } catch (e) {
      debugPrint('Error calculating investment balance: $e');
      return 0.0;
    }
  }

  // Calculate total income for a period
  Future<double> calculateTotalIncome({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await _databaseService.getAllTransactions();
      double totalIncome = 0.0;

      for (final transaction in transactions) {
        final amount = transaction['amount'] as double? ?? 0.0;
        final type = transaction['type'] as String? ?? 'expense';
        final dateStr = transaction['date'] as String? ?? '';

        if (type == 'income') {
          // Parse date if filtering by date range
          if (startDate != null && endDate != null) {
            try {
              final transactionDate = DateTime.parse(dateStr);
              if (transactionDate.isAfter(
                    startDate.subtract(const Duration(days: 1)),
                  ) &&
                  transactionDate.isBefore(
                    endDate.add(const Duration(days: 1)),
                  )) {
                totalIncome += amount;
              }
            } catch (e) {
              // If date parsing fails, include the transaction
              totalIncome += amount;
            }
          } else {
            totalIncome += amount;
          }
        }
      }

      debugPrint('Calculated total income: $totalIncome');
      return totalIncome;
    } catch (e) {
      debugPrint('Error calculating total income: $e');
      return 0.0;
    }
  }

  // Calculate total expenses for a period
  Future<double> calculateTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await _databaseService.getAllTransactions();
      double totalExpenses = 0.0;

      for (final transaction in transactions) {
        final amount = transaction['amount'] as double? ?? 0.0;
        final type = transaction['type'] as String? ?? 'expense';
        final dateStr = transaction['date'] as String? ?? '';

        if (type == 'expense') {
          // Parse date if filtering by date range
          if (startDate != null && endDate != null) {
            try {
              final transactionDate = DateTime.parse(dateStr);
              if (transactionDate.isAfter(
                    startDate.subtract(const Duration(days: 1)),
                  ) &&
                  transactionDate.isBefore(
                    endDate.add(const Duration(days: 1)),
                  )) {
                totalExpenses += amount.abs(); // Ensure positive value
              }
            } catch (e) {
              // If date parsing fails, include the transaction
              totalExpenses += amount.abs();
            }
          } else {
            totalExpenses += amount.abs();
          }
        }
      }

      debugPrint('Calculated total expenses: $totalExpenses');
      return totalExpenses;
    } catch (e) {
      debugPrint('Error calculating total expenses: $e');
      return 0.0;
    }
  }

  // Calculate spending by category
  Future<Map<String, double>> calculateSpendingByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await _databaseService.getAllTransactions();
      final Map<String, double> categorySpending = {};

      for (final transaction in transactions) {
        final amount = transaction['amount'] as double? ?? 0.0;
        final type = transaction['type'] as String? ?? 'expense';
        final category = transaction['category'] as String? ?? 'Other';
        final dateStr = transaction['date'] as String? ?? '';

        if (type == 'expense') {
          // Parse date if filtering by date range
          bool includeTransaction = true;
          if (startDate != null && endDate != null) {
            try {
              final transactionDate = DateTime.parse(dateStr);
              includeTransaction =
                  transactionDate.isAfter(
                    startDate.subtract(const Duration(days: 1)),
                  ) &&
                  transactionDate.isBefore(
                    endDate.add(const Duration(days: 1)),
                  );
            } catch (e) {
              // If date parsing fails, include the transaction
              includeTransaction = true;
            }
          }

          if (includeTransaction) {
            categorySpending[category] =
                (categorySpending[category] ?? 0.0) + amount.abs();
          }
        }
      }

      debugPrint('Calculated spending by category: $categorySpending');
      return categorySpending;
    } catch (e) {
      debugPrint('Error calculating spending by category: $e');
      return {};
    }
  }

  // Calculate budget spent amount
  Future<double> calculateBudgetSpent(
    String period, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await _databaseService.getAllTransactions();
      double spentAmount = 0.0;

      for (final transaction in transactions) {
        final amount = transaction['amount'] as double? ?? 0.0;
        final type = transaction['type'] as String? ?? 'expense';
        final dateStr = transaction['date'] as String? ?? '';

        if (type == 'expense') {
          // Parse date if filtering by date range
          bool includeTransaction = true;
          if (startDate != null && endDate != null) {
            try {
              final transactionDate = DateTime.parse(dateStr);
              includeTransaction =
                  transactionDate.isAfter(
                    startDate.subtract(const Duration(days: 1)),
                  ) &&
                  transactionDate.isBefore(
                    endDate.add(const Duration(days: 1)),
                  );
            } catch (e) {
              // If date parsing fails, include the transaction
              includeTransaction = true;
            }
          }

          if (includeTransaction) {
            spentAmount += amount.abs();
          }
        }
      }

      debugPrint('Calculated budget spent for $period: $spentAmount');
      return spentAmount;
    } catch (e) {
      debugPrint('Error calculating budget spent: $e');
      return 0.0;
    }
  }

  // Recalculate all balances and update database
  Future<void> recalculateAllBalances() async {
    try {
      debugPrint('Starting balance recalculation...');

      // Calculate all balances
      final currentBalance = await calculateCurrentBalance();
      final emergencyBalance = await calculateEmergencyBalance();
      final investmentBalance = await calculateInvestmentBalance();

      // Update database with calculated balances
      await _databaseService.setSetting('current_balance', currentBalance);
      await _databaseService.setSetting('emergency_balance', emergencyBalance);
      await _databaseService.setSetting(
        'investment_balance',
        investmentBalance,
      );

      // Update budget spent amounts
      await _updateBudgetSpentAmounts();

      debugPrint('Balance recalculation completed successfully');
    } catch (e) {
      debugPrint('Error recalculating balances: $e');
      rethrow;
    }
  }

  // Update budget spent amounts
  Future<void> _updateBudgetSpentAmounts() async {
    try {
      final now = DateTime.now();

      // Weekly budget spent
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weeklySpent = await calculateBudgetSpent(
        'weekly',
        startDate: weekStart,
        endDate: weekEnd,
      );
      await _databaseService.setSetting('weekly_budget_spent', weeklySpent);

      // Monthly budget spent
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);
      final monthlySpent = await calculateBudgetSpent(
        'monthly',
        startDate: monthStart,
        endDate: monthEnd,
      );
      await _databaseService.setSetting('monthly_budget_spent', monthlySpent);

      // Yearly budget spent
      final yearStart = DateTime(now.year, 1, 1);
      final yearEnd = DateTime(now.year, 12, 31);
      final yearlySpent = await calculateBudgetSpent(
        'yearly',
        startDate: yearStart,
        endDate: yearEnd,
      );
      await _databaseService.setSetting('yearly_budget_spent', yearlySpent);

      debugPrint('Budget spent amounts updated successfully');
    } catch (e) {
      debugPrint('Error updating budget spent amounts: $e');
    }
  }

  // Validate transaction data consistency
  Future<bool> validateTransactionConsistency() async {
    try {
      final transactions = await _databaseService.getAllTransactions();

      for (final transaction in transactions) {
        final amount = transaction['amount'] as double? ?? 0.0;
        final type = transaction['type'] as String? ?? 'expense';

        // Check if income transactions have positive amounts
        if (type == 'income' && amount <= 0) {
          debugPrint('Invalid income transaction: amount should be positive');
          return false;
        }

        // Check if expense transactions have negative amounts
        if (type == 'expense' && amount >= 0) {
          debugPrint('Invalid expense transaction: amount should be negative');
          return false;
        }
      }

      debugPrint('Transaction consistency validation passed');
      return true;
    } catch (e) {
      debugPrint('Error validating transaction consistency: $e');
      return false;
    }
  }
}
