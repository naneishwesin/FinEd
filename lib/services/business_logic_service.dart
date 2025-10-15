// lib/services/business_logic_service.dart
import 'data_validation_service.dart';
import 'database_service.dart';

class BusinessLogicService {
  final DatabaseService _dbService = DatabaseService();

  // Financial Health Scoring
  Future<Map<String, dynamic>> calculateFinancialHealth() async {
    try {
      final emergencyBalance = await _dbService.getEmergencyBalance();
      final totalIncome = await _dbService.getTotalIncome();
      final totalExpenses = await _dbService.getTotalExpenses();
      final investments = await _dbService.getInvestments();

      // Calculate financial health score (0-100)
      int score = 0;
      final recommendations = <String>[];

      // Emergency fund ratio (should be 3-6 months of expenses)
      final monthlyExpenses = totalExpenses / 12;
      final emergencyRatio = monthlyExpenses > 0
          ? emergencyBalance / monthlyExpenses
          : 0;

      if (emergencyRatio >= 6) {
        score += 25;
      } else if (emergencyRatio >= 3) {
        score += 20;
        recommendations.add(
          'Consider building emergency fund to 6 months of expenses',
        );
      } else if (emergencyRatio >= 1) {
        score += 10;
        recommendations.add(
          'Build emergency fund to at least 3 months of expenses',
        );
      } else {
        recommendations.add('Priority: Build emergency fund immediately');
      }

      // Savings rate (income vs expenses)
      final savingsRate = totalIncome > 0
          ? (totalIncome - totalExpenses) / totalIncome
          : 0;
      if (savingsRate >= 0.2) {
        score += 25;
      } else if (savingsRate >= 0.1) {
        score += 20;
        recommendations.add('Aim for 20% savings rate');
      } else if (savingsRate >= 0) {
        score += 10;
        recommendations.add('Increase savings rate to at least 10%');
      } else {
        score += 0;
        recommendations.add('Reduce expenses or increase income');
      }

      // Investment diversification
      final totalInvestmentValue = investments.fold(
        0.0,
        (sum, inv) => sum + (inv['amount'] as double),
      );
      if (totalInvestmentValue > 0) {
        score += 25;
        if (investments.length < 3) {
          recommendations.add('Consider diversifying investments');
        }
      } else {
        recommendations.add('Start investing for long-term wealth building');
      }

      // Debt-to-income ratio (simplified)
      final debtRatio = totalExpenses > 0
          ? (totalExpenses - totalIncome) / totalIncome
          : 0;
      if (debtRatio <= 0) {
        score += 25;
      } else if (debtRatio <= 0.1) {
        score += 20;
        recommendations.add('Keep debt-to-income ratio below 10%');
      } else {
        score += 5;
        recommendations.add('Reduce debt-to-income ratio');
      }

      return {
        'score': score,
        'emergencyRatio': emergencyRatio,
        'savingsRate': savingsRate,
        'totalInvestmentValue': totalInvestmentValue,
        'debtRatio': debtRatio,
        'recommendations': recommendations,
        'status': _getHealthStatus(score),
      };
    } catch (e) {
      print('Error calculating financial health: $e');
      return {
        'score': 0,
        'status': 'Unknown',
        'recommendations': ['Unable to calculate financial health'],
      };
    }
  }

  String _getHealthStatus(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Critical';
  }

  /// Process a new transaction with business rules
  Future<TransactionResult> processTransaction(
    Map<String, dynamic> transaction,
  ) async {
    try {
      // 1. Validate transaction data
      final validation = DataValidationService.validateTransaction(transaction);
      if (!validation.isValid) {
        return TransactionResult(
          success: false,
          message: 'Validation failed: ${validation.errors.join(', ')}',
        );
      }

      // 2. Apply business rules
      final businessRules = await _applyBusinessRules(transaction);
      if (!businessRules.success) {
        return businessRules;
      }

      // 3. Insert transaction
      final id = await _dbService.insertTransaction(transaction);

      // 4. Update related data
      await _updateRelatedData(transaction);

      // 5. Check for alerts
      final alerts = await _checkTransactionAlerts(transaction);

      return TransactionResult(
        success: true,
        message: 'Transaction added successfully',
        transactionId: id,
        alerts: alerts,
      );
    } catch (e) {
      return TransactionResult(
        success: false,
        message: 'Error processing transaction: $e',
      );
    }
  }

  /// Apply business rules to transaction
  Future<TransactionResult> _applyBusinessRules(
    Map<String, dynamic> transaction,
  ) async {
    final amount = transaction['amount'] as double;
    final type = transaction['type'] as String;

    // Rule 1: Check for suspiciously large transactions
    if (amount > 50000) {
      return TransactionResult(
        success: false,
        message: 'Transaction amount exceeds maximum limit of 50,000',
      );
    }

    // Rule 2: Check for negative income
    if (type == 'income' && amount < 0) {
      return TransactionResult(
        success: false,
        message: 'Income transactions cannot be negative',
      );
    }

    // Rule 3: Check for positive expenses
    if (type == 'expense' && amount > 0) {
      // Convert to negative for expenses
      transaction['amount'] = -amount;
    }

    // Rule 4: Check budget constraints
    final budgetCheck = await _checkBudgetConstraints(transaction);
    if (!budgetCheck.success) {
      return budgetCheck;
    }

    // Rule 5: Check for duplicate transactions
    final duplicateCheck = await _checkDuplicateTransaction(transaction);
    if (!duplicateCheck.success) {
      return duplicateCheck;
    }

    return TransactionResult(success: true);
  }

  /// Check budget constraints
  Future<TransactionResult> _checkBudgetConstraints(
    Map<String, dynamic> transaction,
  ) async {
    if (transaction['type'] != 'expense') {
      return TransactionResult(success: true);
    }

    final amount = (transaction['amount'] as double).abs();
    final budgets = await _dbService.getAllBudgets();

    for (final budget in budgets) {
      final budgetAmount = budget['amount'] as double? ?? 0;
      final budgetSpent = budget['spent'] as double? ?? 0;
      final budgetType = budget['type'] as String;

      if (budgetAmount > 0) {
        final remaining = budgetAmount - budgetSpent;
        if (amount > remaining) {
          return TransactionResult(
            success: false,
            message:
                'Transaction would exceed $budgetType budget by ${amount - remaining}',
          );
        }
      }
    }

    return TransactionResult(success: true);
  }

  /// Check for duplicate transactions
  Future<TransactionResult> _checkDuplicateTransaction(
    Map<String, dynamic> transaction,
  ) async {
    final amount = transaction['amount'] as double;
    final category = transaction['category'] as String;
    final date = transaction['date'] as String;

    // Check for transactions with same amount, category, and date
    final transactions = await _dbService.getTransactionsByDateRange(
      DateTime.parse(date),
      DateTime.parse(date),
    );
    final duplicates = transactions.where(
      (t) =>
          t['amount'] == amount &&
          t['category'] == category &&
          t['type'] == transaction['type'],
    );

    if (duplicates.length >= 3) {
      return TransactionResult(
        success: false,
        message: 'Too many similar transactions on the same day',
      );
    }

    return TransactionResult(success: true);
  }

  /// Update related data after transaction
  Future<void> _updateRelatedData(Map<String, dynamic> transaction) async {
    // Update emergency fund if applicable
    if (transaction['category'] == 'Emergency Fund') {
      await _updateEmergencyFund(transaction);
    }

    // Update investment if applicable
    if (transaction['category'] == 'Investment') {
      await _updateInvestment(transaction);
    }

    // Update financial goals
    await _updateFinancialGoals(transaction);
  }

  /// Update emergency fund
  Future<void> _updateEmergencyFund(Map<String, dynamic> transaction) async {
    final amount = transaction['amount'] as double;
    final emergencyFunds = await _dbService.getAllEmergencyFunds();

    if (emergencyFunds.isNotEmpty) {
      final fund = emergencyFunds.first;
      final currentAmount = fund['current_amount'] as double? ?? 0;
      final newAmount = currentAmount + amount;

      await _dbService.updateEmergencyFund(fund['id'] as int, {
        'name': fund['name'],
        'target_amount': fund['target_amount'],
        'current_amount': newAmount,
        'priority': fund['priority'],
      });
    }
  }

  /// Update investment
  Future<void> _updateInvestment(Map<String, dynamic> transaction) async {
    final amount = transaction['amount'] as double;
    final investments = await _dbService.getAllInvestments();

    if (investments.isNotEmpty) {
      final investment = investments.first;
      final currentPrice =
          investment['current_price'] as double? ??
          investment['purchase_price'] as double;
      final quantity = investment['quantity'] as double;
      final newQuantity = quantity + (amount / currentPrice);

      await _dbService.updateInvestment(investment['id'] as int, {
        'name': investment['name'],
        'type': investment['type'],
        'symbol': investment['symbol'],
        'quantity': newQuantity,
        'purchase_price': investment['purchase_price'],
        'current_price': currentPrice,
        'purchase_date': investment['purchase_date'],
      });
    }
  }

  /// Update financial goals
  Future<void> _updateFinancialGoals(Map<String, dynamic> transaction) async {
    final amount = transaction['amount'] as double;
    final goals = await _dbService.getAllFinancialGoals();

    for (final goal in goals) {
      if (goal['status'] == 'active') {
        final currentAmount = goal['current_amount'] as double? ?? 0;
        final newAmount = currentAmount + amount;

        await _dbService.updateFinancialGoal(goal['id'] as int, {
          'title': goal['title'],
          'target_amount': goal['target_amount'],
          'current_amount': newAmount,
          'target_date': goal['target_date'],
          'category': goal['category'],
          'priority': goal['priority'],
          'status': newAmount >= (goal['target_amount'] as double)
              ? 'completed'
              : 'active',
        });
      }
    }
  }

  /// Check for transaction alerts
  Future<List<TransactionAlert>> _checkTransactionAlerts(
    Map<String, dynamic> transaction,
  ) async {
    final alerts = <TransactionAlert>[];

    // Check budget alerts
    if (transaction['type'] == 'expense') {
      final amount = (transaction['amount'] as double).abs();
      final budgets = await _dbService.getAllBudgets();

      for (final budget in budgets) {
        final budgetAmount = budget['amount'] as double? ?? 0;
        final budgetSpent = budget['spent'] as double? ?? 0;
        final budgetType = budget['type'] as String;

        if (budgetAmount > 0) {
          final newSpent = budgetSpent + amount;
          final percentage = newSpent / budgetAmount;

          if (percentage >= 1.0) {
            alerts.add(
              TransactionAlert(
                type: AlertType.budget_exceeded,
                message: 'You have exceeded your $budgetType budget',
                severity: AlertSeverity.critical,
              ),
            );
          } else if (percentage >= 0.8) {
            alerts.add(
              TransactionAlert(
                type: AlertType.budget_warning,
                message: 'You are approaching your $budgetType budget limit',
                severity: AlertSeverity.warning,
              ),
            );
          }
        }
      }
    }

    // Check goal completion alerts
    final goals = await _dbService.getAllFinancialGoals();
    for (final goal in goals) {
      if (goal['status'] == 'active') {
        final targetAmount = goal['target_amount'] as double? ?? 0;
        final currentAmount = goal['current_amount'] as double? ?? 0;

        if (currentAmount >= targetAmount) {
          alerts.add(
            TransactionAlert(
              type: AlertType.goal_completed,
              message:
                  'Congratulations! You have completed your goal: ${goal['title']}',
              severity: AlertSeverity.success,
            ),
          );
        }
      }
    }

    return alerts;
  }

  /// Process recurring transactions
  Future<void> processRecurringTransactions() async {
    final recurringTransactions = await _dbService
        .getAllRecurringTransactions();
    final now = DateTime.now();

    for (final recurring in recurringTransactions) {
      if (recurring['is_active'] == 1) {
        final nextDueDate = DateTime.parse(
          recurring['next_due_date'] as String,
        );

        if (now.isAfter(nextDueDate)) {
          // Create transaction from recurring
          final transaction = {
            'category': recurring['category'],
            'amount': recurring['amount'],
            'date': now.toIso8601String().split('T')[0],
            'time': now.toIso8601String().split('T')[1].split('.')[0],
            'asset': 'Cash',
            'ledger': 'Main',
            'remark': 'Recurring: ${recurring['title']}',
            'type': 'expense',
          };

          await processTransaction(transaction);

          // Update next due date
          final frequency = recurring['frequency'] as String;
          DateTime newDueDate;

          switch (frequency) {
            case 'daily':
              newDueDate = nextDueDate.add(Duration(days: 1));
              break;
            case 'weekly':
              newDueDate = nextDueDate.add(Duration(days: 7));
              break;
            case 'monthly':
              newDueDate = DateTime(
                nextDueDate.year,
                nextDueDate.month + 1,
                nextDueDate.day,
              );
              break;
            case 'yearly':
              newDueDate = DateTime(
                nextDueDate.year + 1,
                nextDueDate.month,
                nextDueDate.day,
              );
              break;
            default:
              newDueDate = nextDueDate.add(Duration(days: 1));
          }

          await _dbService.updateRecurringTransaction(recurring['id'] as int, {
            'title': recurring['title'],
            'amount': recurring['amount'],
            'category': recurring['category'],
            'frequency': recurring['frequency'],
            'next_due_date': newDueDate.toIso8601String().split('T')[0],
            'is_active': recurring['is_active'],
          });
        }
      }
    }
  }

  /// Calculate financial recommendations
  Future<List<FinancialRecommendation>> getFinancialRecommendations() async {
    final recommendations = <FinancialRecommendation>[];

    // Get current financial data
    final currentBalance = await _dbService.getCurrentBalance();
    final emergencyBalance = await _dbService.getEmergencyBalance();
    final investmentBalance = await _dbService.getInvestmentBalance();
    final totalLiabilities = await _dbService.getTotalLiabilities();
    final monthlyIncome = await _getMonthlyIncome();
    final monthlyExpenses = await _getMonthlyExpenses();

    // Emergency fund recommendation
    if (emergencyBalance < monthlyExpenses * 3) {
      recommendations.add(
        FinancialRecommendation(
          type: RecommendationType.emergency_fund,
          priority: Priority.high,
          title: 'Build Emergency Fund',
          description: 'Aim for 3-6 months of expenses in emergency fund',
          action:
              'Set aside ${(monthlyExpenses * 3 - emergencyBalance).toStringAsFixed(0)} more',
        ),
      );
    }

    // Investment recommendation
    if (investmentBalance < monthlyIncome * 6) {
      recommendations.add(
        FinancialRecommendation(
          type: RecommendationType.investment,
          priority: Priority.medium,
          title: 'Increase Investments',
          description: 'Consider investing more for long-term wealth building',
          action: 'Aim for at least 6 months of income in investments',
        ),
      );
    }

    // Debt reduction recommendation
    if (totalLiabilities > monthlyIncome * 12) {
      recommendations.add(
        FinancialRecommendation(
          type: RecommendationType.debt_reduction,
          priority: Priority.high,
          title: 'Reduce Debt',
          description: 'Your debt is more than 12 months of income',
          action: 'Focus on paying down high-interest debt first',
        ),
      );
    }

    // Savings rate recommendation
    final savingsRate = monthlyIncome > 0
        ? (monthlyIncome - monthlyExpenses) / monthlyIncome
        : 0;
    if (savingsRate < 0.15) {
      recommendations.add(
        FinancialRecommendation(
          type: RecommendationType.savings_rate,
          priority: Priority.medium,
          title: 'Increase Savings Rate',
          description: 'Aim for at least 15% savings rate',
          action: 'Reduce expenses or increase income',
        ),
      );
    }

    return recommendations;
  }

  /// Get monthly income
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

  /// Get monthly expenses
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
        .fold<double>(
          0.0,
          (sum, t) => sum + (t['amount'] as num).toDouble().abs(),
        );
  }
}

class TransactionResult {
  final bool success;
  final String message;
  final int? transactionId;
  final List<TransactionAlert>? alerts;

  TransactionResult({
    required this.success,
    this.message = '',
    this.transactionId,
    this.alerts,
  });
}

class TransactionAlert {
  final AlertType type;
  final String message;
  final AlertSeverity severity;

  TransactionAlert({
    required this.type,
    required this.message,
    required this.severity,
  });
}

class FinancialRecommendation {
  final RecommendationType type;
  final Priority priority;
  final String title;
  final String description;
  final String action;

  FinancialRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.action,
  });
}

enum AlertType {
  budget_exceeded,
  budget_warning,
  goal_completed,
  low_balance,
  high_expense,
}

enum AlertSeverity { success, warning, critical }

enum RecommendationType {
  emergency_fund,
  investment,
  debt_reduction,
  savings_rate,
  budget_optimization,
}

enum Priority { low, medium, high }
