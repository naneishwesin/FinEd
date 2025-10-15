// lib/services/error_handling_service.dart
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'database_service.dart';

class ErrorHandlingService {
  final DatabaseService _dbService = DatabaseService();
  static final ErrorHandlingService _instance =
      ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  /// Global error handler
  static void initializeErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error', details.exception, details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      return true;
    };
  }

  /// Log error with context
  static void _logError(String type, dynamic error, StackTrace? stack) {
    print('$type: $error');
    if (stack != null) {
      print('Stack trace: $stack');
    }

    // Here you would typically send to crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }

  /// Handle database errors
  Future<T> handleDatabaseOperation<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } on Exception catch (e) {
      _logError(
        'Database Error${context != null ? ' in $context' : ''}',
        e,
        null,
      );

      if (fallbackValue != null) {
        return fallbackValue;
      }

      rethrow;
    } catch (e) {
      _logError(
        'Unexpected Error${context != null ? ' in $context' : ''}',
        e,
        null,
      );

      if (fallbackValue != null) {
        return fallbackValue;
      }

      rethrow;
    }
  }

  /// Handle network errors
  Future<T> handleNetworkOperation<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } on SocketException catch (e) {
      _logError(
        'Network Error${context != null ? ' in $context' : ''}',
        e,
        null,
      );

      if (fallbackValue != null) {
        return fallbackValue;
      }

      rethrow;
    } catch (e) {
      _logError(
        'Network Operation Error${context != null ? ' in $context' : ''}',
        e,
        null,
      );

      if (fallbackValue != null) {
        return fallbackValue;
      }

      rethrow;
    }
  }

  /// Show user-friendly error message
  void showError(BuildContext context, String message, {String? title}) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show success message
  void showSuccess(BuildContext context, String message, {String? title}) {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message
  void showWarning(BuildContext context, String message, {String? title}) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Warning'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Validate data integrity
  Future<DataIntegrityReport> validateDataIntegrity() async {
    final issues = <DataIntegrityIssue>[];

    try {
      // Check transaction data integrity
      await _validateTransactions(issues);

      // Check balance consistency
      await _validateBalances(issues);

      // Check budget consistency
      await _validateBudgets(issues);

      // Check category consistency
      await _validateCategories(issues);

      // Check foreign key relationships
      await _validateForeignKeys(issues);

      return DataIntegrityReport(
        isValid: issues.isEmpty,
        issues: issues,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      issues.add(
        DataIntegrityIssue(
          type: IssueType.validation_error,
          severity: IssueSeverity.critical,
          message: 'Failed to validate data integrity: $e',
          table: 'all',
        ),
      );

      return DataIntegrityReport(
        isValid: false,
        issues: issues,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Validate transaction data
  Future<void> _validateTransactions(List<DataIntegrityIssue> issues) async {
    final transactions = await _dbService.getAllTransactions();

    for (final transaction in transactions) {
      // Check for null required fields
      if (transaction['category'] == null ||
          transaction['category'].toString().isEmpty) {
        issues.add(
          DataIntegrityIssue(
            type: IssueType.null_value,
            severity: IssueSeverity.high,
            message: 'Transaction has null or empty category',
            table: 'transactions',
            recordId: transaction['id'],
          ),
        );
      }

      if (transaction['amount'] == null) {
        issues.add(
          DataIntegrityIssue(
            type: IssueType.null_value,
            severity: IssueSeverity.high,
            message: 'Transaction has null amount',
            table: 'transactions',
            recordId: transaction['id'],
          ),
        );
      }

      if (transaction['type'] == null ||
          transaction['type'].toString().isEmpty) {
        issues.add(
          DataIntegrityIssue(
            type: IssueType.null_value,
            severity: IssueSeverity.high,
            message: 'Transaction has null or empty type',
            table: 'transactions',
            recordId: transaction['id'],
          ),
        );
      }

      // Check for invalid date format
      if (transaction['date'] != null) {
        try {
          DateTime.parse(transaction['date'].toString());
        } catch (e) {
          issues.add(
            DataIntegrityIssue(
              type: IssueType.invalid_format,
              severity: IssueSeverity.medium,
              message: 'Transaction has invalid date format',
              table: 'transactions',
              recordId: transaction['id'],
            ),
          );
        }
      }
    }
  }

  /// Validate balance consistency
  Future<void> _validateBalances(List<DataIntegrityIssue> issues) async {
    final currentBalance = await _dbService.getCurrentBalance();
    final transactions = await _dbService.getAllTransactions();

    // Calculate expected balance from transactions
    final expectedBalance = transactions.fold(
      0.0,
      (sum, t) => sum + (t['amount'] as double),
    );

    // Check if balances match (allow for small floating point differences)
    if ((currentBalance - expectedBalance).abs() > 0.01) {
      issues.add(
        DataIntegrityIssue(
          type: IssueType.data_inconsistency,
          severity: IssueSeverity.high,
          message:
              'Current balance ($currentBalance) does not match transaction sum ($expectedBalance)',
          table: 'balances',
        ),
      );
    }
  }

  /// Validate budget consistency
  Future<void> _validateBudgets(List<DataIntegrityIssue> issues) async {
    final budgets = await _dbService.getAllBudgets();

    for (final budget in budgets) {
      final amount = budget['amount'] as double? ?? 0;
      final spent = budget['spent'] as double? ?? 0;

      if (amount < 0) {
        issues.add(
          DataIntegrityIssue(
            type: IssueType.invalid_value,
            severity: IssueSeverity.medium,
            message: 'Budget amount is negative',
            table: 'budgets',
            recordId: budget['id'],
          ),
        );
      }

      if (spent < 0) {
        issues.add(
          DataIntegrityIssue(
            type: IssueType.invalid_value,
            severity: IssueSeverity.medium,
            message: 'Budget spent amount is negative',
            table: 'budgets',
            recordId: budget['id'],
          ),
        );
      }
    }
  }

  /// Validate category consistency
  Future<void> _validateCategories(List<DataIntegrityIssue> issues) async {
    final transactions = await _dbService.getAllTransactions();
    final categories = await _dbService.getAllCategories();

    final categoryNames = categories.map((c) => c['name'] as String).toSet();

    for (final transaction in transactions) {
      final category = transaction['category'] as String?;
      if (category != null && !categoryNames.contains(category)) {
        issues.add(
          DataIntegrityIssue(
            type: IssueType.orphaned_record,
            severity: IssueSeverity.medium,
            message: 'Transaction references non-existent category: $category',
            table: 'transactions',
            recordId: transaction['id'],
          ),
        );
      }
    }
  }

  /// Validate foreign key relationships
  Future<void> _validateForeignKeys(List<DataIntegrityIssue> issues) async {
    // Check if all transactions have valid categories
    final transactions = await _dbService.getAllTransactions();
    final categories = await _dbService.getAllCategories();

    final categoryNames = categories.map((c) => c['name'] as String).toSet();

    for (final transaction in transactions) {
      final category = transaction['category'] as String?;
      if (category != null && !categoryNames.contains(category)) {
        issues.add(
          DataIntegrityIssue(
            type: IssueType.foreign_key_violation,
            severity: IssueSeverity.high,
            message: 'Transaction references non-existent category: $category',
            table: 'transactions',
            recordId: transaction['id'],
          ),
        );
      }
    }
  }

  /// Fix data integrity issues
  Future<void> fixDataIntegrityIssues(List<DataIntegrityIssue> issues) async {
    for (final issue in issues) {
      try {
        switch (issue.type) {
          case IssueType.null_value:
            await _fixNullValue(issue);
            break;
          case IssueType.invalid_format:
            await _fixInvalidFormat(issue);
            break;
          case IssueType.data_inconsistency:
            await _fixDataInconsistency(issue);
            break;
          case IssueType.invalid_value:
            await _fixInvalidValue(issue);
            break;
          case IssueType.orphaned_record:
            await _fixOrphanedRecord(issue);
            break;
          case IssueType.foreign_key_violation:
            await _fixForeignKeyViolation(issue);
            break;
          case IssueType.validation_error:
            // Cannot auto-fix validation errors
            break;
        }
      } catch (e) {
        print('Failed to fix issue ${issue.message}: $e');
      }
    }
  }

  /// Fix null value issues
  Future<void> _fixNullValue(DataIntegrityIssue issue) async {
    if (issue.table == 'transactions' && issue.recordId != null) {
      // Set default values for null fields
      final transaction = await _dbService.getTransactionById(issue.recordId!);
      if (transaction != null) {
        final updates = <String, dynamic>{};

        if (transaction['category'] == null) {
          updates['category'] = 'Other';
        }

        if (transaction['type'] == null) {
          updates['type'] = 'expense';
        }

        if (updates.isNotEmpty) {
          await _dbService.updateTransaction(issue.recordId!, updates);
        }
      }
    }
  }

  /// Fix invalid format issues
  Future<void> _fixInvalidFormat(DataIntegrityIssue issue) async {
    if (issue.table == 'transactions' && issue.recordId != null) {
      final transaction = await _dbService.getTransactionById(issue.recordId!);
      if (transaction != null && transaction['date'] != null) {
        try {
          // Try to parse and reformat the date
          final date = DateTime.parse(transaction['date'].toString());
          await _dbService.updateTransaction(issue.recordId!, {
            'date': date.toIso8601String().split('T')[0],
          });
        } catch (e) {
          // If parsing fails, set to current date
          await _dbService.updateTransaction(issue.recordId!, {
            'date': DateTime.now().toIso8601String().split('T')[0],
          });
        }
      }
    }
  }

  /// Fix data inconsistency issues
  Future<void> _fixDataInconsistency(DataIntegrityIssue issue) async {
    if (issue.table == 'balances') {
      // Recalculate balances from transactions
      await _dbService.recalculateAllBalances();
    }
  }

  /// Fix invalid value issues
  Future<void> _fixInvalidValue(DataIntegrityIssue issue) async {
    if (issue.table == 'budgets' && issue.recordId != null) {
      final budget = await _dbService.getBudgetByType(
        'monthly',
      ); // Assuming monthly budget
      if (budget != null) {
        final updates = <String, dynamic>{};

        if (budget['amount'] < 0) {
          updates['amount'] = 0.0;
        }

        if (budget['spent'] < 0) {
          updates['spent'] = 0.0;
        }

        if (updates.isNotEmpty) {
          await _dbService.updateBudget(budget['id'], updates);
        }
      }
    }
  }

  /// Fix orphaned record issues
  Future<void> _fixOrphanedRecord(DataIntegrityIssue issue) async {
    if (issue.table == 'transactions' && issue.recordId != null) {
      // Set category to 'Other' for orphaned records
      await _dbService.updateTransaction(issue.recordId!, {
        'category': 'Other',
      });
    }
  }

  /// Fix foreign key violation issues
  Future<void> _fixForeignKeyViolation(DataIntegrityIssue issue) async {
    if (issue.table == 'transactions' && issue.recordId != null) {
      // Set category to 'Other' for foreign key violations
      await _dbService.updateTransaction(issue.recordId!, {
        'category': 'Other',
      });
    }
  }

  /// Show data integrity report
  void showDataIntegrityReport(
    BuildContext context,
    DataIntegrityReport report,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Data Integrity Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${report.isValid ? 'Valid' : 'Issues Found'}'),
              Text('Issues: ${report.issues.length}'),
              Text('Timestamp: ${report.timestamp}'),
              if (report.issues.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('Issues:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...report.issues.map(
                  (issue) => Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text('• ${issue.message}'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (report.issues.isNotEmpty)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await fixDataIntegrityIssues(report.issues);
                showSuccess(context, 'Data integrity issues fixed');
              },
              child: Text('Fix Issues'),
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

class DataIntegrityReport {
  final bool isValid;
  final List<DataIntegrityIssue> issues;
  final DateTime timestamp;

  DataIntegrityReport({
    required this.isValid,
    required this.issues,
    required this.timestamp,
  });
}

class DataIntegrityIssue {
  final IssueType type;
  final IssueSeverity severity;
  final String message;
  final String table;
  final int? recordId;

  DataIntegrityIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.table,
    this.recordId,
  });
}

enum IssueType {
  null_value,
  invalid_format,
  data_inconsistency,
  invalid_value,
  orphaned_record,
  foreign_key_violation,
  validation_error,
}

enum IssueSeverity { low, medium, high, critical }
