// lib/services/financial_health_service.dart
import 'package:flutter/material.dart';

import 'database_service.dart';

class FinancialHealthService {
  final DatabaseService _dbService = DatabaseService();

  /// Calculate overall financial health score (0-100)
  Future<FinancialHealthScore> calculateFinancialHealthScore() async {
    try {
      // Get all financial data
      final currentBalance = await _dbService.getCurrentBalance();
      final emergencyBalance = await _dbService.getEmergencyBalance();
      final investmentBalance = await _dbService.getInvestmentBalance();
      final totalAssets = await _dbService.getTotalAssets();
      final totalLiabilities = await _dbService.getTotalLiabilities();
      final monthlyIncome = await _getMonthlyIncome();
      final monthlyExpenses = await _getMonthlyExpenses();
      final budgets = await _dbService.getAllBudgets();
      final goals = await _dbService.getAllFinancialGoals();

      // Calculate individual scores
      final emergencyScore = _calculateEmergencyFundScore(
        emergencyBalance,
        monthlyExpenses,
      );
      final savingsScore = _calculateSavingsRateScore(
        monthlyIncome,
        monthlyExpenses,
      );
      final debtScore = _calculateDebtToIncomeScore(
        totalLiabilities,
        monthlyIncome,
      );
      final budgetScore = _calculateBudgetAdherenceScore(budgets);
      final goalScore = _calculateGoalProgressScore(goals);
      final netWorthScore = _calculateNetWorthScore(
        totalAssets,
        totalLiabilities,
      );

      // Weighted average
      final overallScore =
          (emergencyScore * 0.25 +
                  savingsScore * 0.20 +
                  debtScore * 0.20 +
                  budgetScore * 0.15 +
                  goalScore * 0.10 +
                  netWorthScore * 0.10)
              .round();

      return FinancialHealthScore(
        overallScore: overallScore,
        emergencyScore: emergencyScore,
        savingsScore: savingsScore,
        debtScore: debtScore,
        budgetScore: budgetScore,
        goalScore: goalScore,
        netWorthScore: netWorthScore,
        recommendations: _generateRecommendations(
          emergencyScore,
          savingsScore,
          debtScore,
          budgetScore,
          goalScore,
          netWorthScore,
        ),
      );
    } catch (e) {
      print('Error calculating financial health score: $e');
      return FinancialHealthScore(
        overallScore: 0,
        emergencyScore: 0,
        savingsScore: 0,
        debtScore: 0,
        budgetScore: 0,
        goalScore: 0,
        netWorthScore: 0,
        recommendations: ['Unable to calculate financial health score'],
      );
    }
  }

  /// Calculate emergency fund score (0-100)
  int _calculateEmergencyFundScore(
    double emergencyBalance,
    double monthlyExpenses,
  ) {
    if (monthlyExpenses <= 0) return 100;

    final monthsCovered = emergencyBalance / monthlyExpenses;

    if (monthsCovered >= 6) return 100;
    if (monthsCovered >= 3) return 80;
    if (monthsCovered >= 1) return 60;
    if (monthsCovered >= 0.5) return 40;
    return 20;
  }

  /// Calculate savings rate score (0-100)
  int _calculateSavingsRateScore(double monthlyIncome, double monthlyExpenses) {
    if (monthlyIncome <= 0) return 0;

    final savingsRate = (monthlyIncome - monthlyExpenses) / monthlyIncome;

    if (savingsRate >= 0.20) return 100; // 20%+ savings rate
    if (savingsRate >= 0.15) return 80; // 15-20% savings rate
    if (savingsRate >= 0.10) return 60; // 10-15% savings rate
    if (savingsRate >= 0.05) return 40; // 5-10% savings rate
    if (savingsRate >= 0) return 20; // Positive savings
    return 0; // Negative savings
  }

  /// Calculate debt-to-income score (0-100)
  int _calculateDebtToIncomeScore(
    double totalLiabilities,
    double monthlyIncome,
  ) {
    if (monthlyIncome <= 0) return 0;

    final annualIncome = monthlyIncome * 12;
    final debtToIncomeRatio = totalLiabilities / annualIncome;

    if (debtToIncomeRatio <= 0.20) return 100; // 20% or less
    if (debtToIncomeRatio <= 0.36) return 80; // 20-36%
    if (debtToIncomeRatio <= 0.50) return 60; // 36-50%
    if (debtToIncomeRatio <= 0.70) return 40; // 50-70%
    return 20; // Over 70%
  }

  /// Calculate budget adherence score (0-100)
  int _calculateBudgetAdherenceScore(List<Map<String, dynamic>> budgets) {
    if (budgets.isEmpty) return 50; // Neutral score if no budgets

    int totalScore = 0;
    int validBudgets = 0;

    for (final budget in budgets) {
      final amount = budget['amount'] as double? ?? 0;
      final spent = budget['spent'] as double? ?? 0;

      if (amount > 0) {
        final adherence = spent / amount;
        if (adherence <= 0.8) {
          totalScore += 100; // Under 80% - excellent
        } else if (adherence <= 1.0) {
          totalScore += 80; // 80-100% - good
        } else {
          totalScore += 40; // Over budget - poor
        }
        validBudgets++;
      }
    }

    return validBudgets > 0 ? (totalScore / validBudgets).round() : 50;
  }

  /// Calculate goal progress score (0-100)
  int _calculateGoalProgressScore(List<Map<String, dynamic>> goals) {
    if (goals.isEmpty) return 50; // Neutral score if no goals

    int totalScore = 0;
    int validGoals = 0;

    for (final goal in goals) {
      final targetAmount = goal['target_amount'] as double? ?? 0;
      final currentAmount = goal['current_amount'] as double? ?? 0;
      final status = goal['status'] as String? ?? 'active';

      if (targetAmount > 0 && status == 'active') {
        final progress = currentAmount / targetAmount;
        if (progress >= 1.0) {
          totalScore += 100; // Completed
        } else if (progress >= 0.75) {
          totalScore += 90; // Almost there
        } else if (progress >= 0.50) {
          totalScore += 70; // Halfway
        } else if (progress >= 0.25) {
          totalScore += 50; // Started
        } else {
          totalScore += 20; // Just started
        }
        validGoals++;
      }
    }

    return validGoals > 0 ? (totalScore / validGoals).round() : 50;
  }

  /// Calculate net worth score (0-100)
  int _calculateNetWorthScore(double totalAssets, double totalLiabilities) {
    final netWorth = totalAssets - totalLiabilities;

    if (netWorth > 0) {
      // Positive net worth - score based on asset-to-liability ratio
      if (totalLiabilities == 0) return 100; // No debt
      final ratio = totalAssets / totalLiabilities;
      if (ratio >= 3.0) return 100; // 3:1 or better
      if (ratio >= 2.0) return 80; // 2:1
      if (ratio >= 1.5) return 60; // 1.5:1
      return 40; // 1:1 to 1.5:1
    } else {
      // Negative net worth
      return 20;
    }
  }

  /// Generate personalized recommendations
  List<String> _generateRecommendations(
    int emergencyScore,
    int savingsScore,
    int debtScore,
    int budgetScore,
    int goalScore,
    int netWorthScore,
  ) {
    final recommendations = <String>[];

    // Emergency fund recommendations
    if (emergencyScore < 60) {
      recommendations.add(
        'Build your emergency fund to cover 3-6 months of expenses',
      );
    }

    // Savings rate recommendations
    if (savingsScore < 60) {
      recommendations.add(
        'Increase your savings rate to at least 10-15% of income',
      );
    }

    // Debt recommendations
    if (debtScore < 60) {
      recommendations.add('Focus on paying down high-interest debt');
    }

    // Budget recommendations
    if (budgetScore < 60) {
      recommendations.add('Create and stick to a monthly budget');
    }

    // Goal recommendations
    if (goalScore < 60) {
      recommendations.add('Set specific financial goals and track progress');
    }

    // Net worth recommendations
    if (netWorthScore < 60) {
      recommendations.add('Focus on building assets and reducing liabilities');
    }

    // General recommendations if all scores are good
    if (recommendations.isEmpty) {
      recommendations.add(
        'Great job! Consider investing for long-term wealth building',
      );
    }

    return recommendations;
  }

  /// Get monthly income from transactions
  Future<double> _getMonthlyIncome() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final transactions = await _dbService.getTransactionsByDateRange(
      startOfMonth,
      endOfMonth,
    );

    return transactions
        .where((t) => t['type'] == 'income')
        .fold<double>(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
  }

  /// Get monthly expenses from transactions
  Future<double> _getMonthlyExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final transactions = await _dbService.getTransactionsByDateRange(
      startOfMonth,
      endOfMonth,
    );

    return transactions
        .where((t) => t['type'] == 'expense')
        .fold<double>(0.0, (sum, t) => sum + (t['amount'] as num).toDouble().abs());
  }

  /// Get financial health trends over time
  Future<List<FinancialHealthTrend>> getFinancialHealthTrends(
    int months,
  ) async {
    final trends = <FinancialHealthTrend>[];
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);

      // Calculate metrics for this month
      final monthlyIncome = await _getMonthlyIncomeForPeriod(month, monthEnd);
      final monthlyExpenses = await _getMonthlyExpensesForPeriod(
        month,
        monthEnd,
      );
      final savingsRate = monthlyIncome > 0
          ? (monthlyIncome - monthlyExpenses) / monthlyIncome
          : 0;

      trends.add(
        FinancialHealthTrend(
          month: month,
          savingsRate: savingsRate.toDouble(),
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
        ),
      );
    }

    return trends;
  }

  /// Get monthly income for a specific period
  Future<double> _getMonthlyIncomeForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await _dbService.getTransactionsByDateRange(
      start,
      end,
    );

    return transactions
        .where((t) => t['type'] == 'income')
        .fold<double>(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
  }

  /// Get monthly expenses for a specific period
  Future<double> _getMonthlyExpensesForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await _dbService.getTransactionsByDateRange(
      start,
      end,
    );

    return transactions
        .where((t) => t['type'] == 'expense')
        .fold<double>(0.0, (sum, t) => sum + (t['amount'] as num).toDouble().abs());
  }

  /// Get budget alerts
  Future<List<BudgetAlert>> getBudgetAlerts() async {
    final alerts = <BudgetAlert>[];
    final budgets = await _dbService.getAllBudgets();

    for (final budget in budgets) {
      final amount = budget['amount'] as double? ?? 0;
      final spent = budget['spent'] as double? ?? 0;
      final type = budget['type'] as String? ?? '';

      if (amount > 0) {
        final percentage = spent / amount;

        if (percentage >= 1.0) {
          alerts.add(
            BudgetAlert(
              type: type,
              severity: AlertSeverity.critical,
              message:
                  'You have exceeded your $type budget by ${((percentage - 1) * 100).toStringAsFixed(1)}%',
              amount: spent - amount,
            ),
          );
        } else if (percentage >= 0.8) {
          alerts.add(
            BudgetAlert(
              type: type,
              severity: AlertSeverity.warning,
              message:
                  'You have used ${(percentage * 100).toStringAsFixed(1)}% of your $type budget',
              amount: amount - spent,
            ),
          );
        }
      }
    }

    return alerts;
  }

  /// Get goal alerts
  Future<List<GoalAlert>> getGoalAlerts() async {
    final alerts = <GoalAlert>[];
    final goals = await _dbService.getAllFinancialGoals();

    for (final goal in goals) {
      final title = goal['title'] as String? ?? '';
      final targetAmount = goal['target_amount'] as double? ?? 0;
      final currentAmount = goal['current_amount'] as double? ?? 0;
      final targetDate = goal['target_date'] as String?;
      final status = goal['status'] as String? ?? 'active';

      if (status == 'active' && targetAmount > 0) {
        final progress = currentAmount / targetAmount;

        // Check if goal is completed
        if (progress >= 1.0) {
          alerts.add(
            GoalAlert(
              title: title,
              severity: AlertSeverity.success,
              message: 'Congratulations! You have completed your goal: $title',
              progress: progress,
            ),
          );
        }
        // Check if goal is behind schedule
        else if (targetDate != null) {
          try {
            final targetDateTime = DateTime.parse(targetDate);
            final now = DateTime.now();
            final totalDays = targetDateTime
                .difference(DateTime(now.year, now.month, 1))
                .inDays;
            final daysPassed = now
                .difference(DateTime(now.year, now.month, 1))
                .inDays;

            if (totalDays > 0) {
              final expectedProgress = daysPassed / totalDays;
              if (progress < expectedProgress * 0.8) {
                alerts.add(
                  GoalAlert(
                    title: title,
                    severity: AlertSeverity.warning,
                    message: 'You are behind schedule on your goal: $title',
                    progress: progress,
                  ),
                );
              }
            }
          } catch (e) {
            // Invalid date format, skip
          }
        }
      }
    }

    return alerts;
  }
}

class FinancialHealthScore {
  final int overallScore;
  final int emergencyScore;
  final int savingsScore;
  final int debtScore;
  final int budgetScore;
  final int goalScore;
  final int netWorthScore;
  final List<String> recommendations;

  FinancialHealthScore({
    required this.overallScore,
    required this.emergencyScore,
    required this.savingsScore,
    required this.debtScore,
    required this.budgetScore,
    required this.goalScore,
    required this.netWorthScore,
    required this.recommendations,
  });

  String get overallRating {
    if (overallScore >= 90) return 'Excellent';
    if (overallScore >= 80) return 'Very Good';
    if (overallScore >= 70) return 'Good';
    if (overallScore >= 60) return 'Fair';
    if (overallScore >= 50) return 'Poor';
    return 'Critical';
  }

  Color get overallColor {
    if (overallScore >= 80) return Colors.green;
    if (overallScore >= 60) return Colors.orange;
    return Colors.red;
  }
}

class FinancialHealthTrend {
  final DateTime month;
  final double savingsRate;
  final double monthlyIncome;
  final double monthlyExpenses;

  FinancialHealthTrend({
    required this.month,
    required this.savingsRate,
    required this.monthlyIncome,
    required this.monthlyExpenses,
  });
}

class BudgetAlert {
  final String type;
  final AlertSeverity severity;
  final String message;
  final double amount;

  BudgetAlert({
    required this.type,
    required this.severity,
    required this.message,
    required this.amount,
  });
}

class GoalAlert {
  final String title;
  final AlertSeverity severity;
  final String message;
  final double progress;

  GoalAlert({
    required this.title,
    required this.severity,
    required this.message,
    required this.progress,
  });
}

enum AlertSeverity { success, warning, critical }
