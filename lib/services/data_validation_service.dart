// lib/services/data_validation_service.dart
import 'package:flutter/material.dart';

class DataValidationService {
  /// Validate transaction data
  static ValidationResult validateTransaction(
    Map<String, dynamic> transaction,
  ) {
    final errors = <String>[];

    // Required fields validation
    if (transaction['category'] == null ||
        transaction['category'].toString().trim().isEmpty) {
      errors.add('Category is required');
    }

    if (transaction['amount'] == null) {
      errors.add('Amount is required');
    } else {
      final amount = double.tryParse(transaction['amount'].toString());
      if (amount == null) {
        errors.add('Amount must be a valid number');
      } else if (amount <= 0) {
        errors.add('Amount must be greater than 0');
      } else if (amount > 1000000) {
        errors.add('Amount cannot exceed 1,000,000');
      }
    }

    if (transaction['date'] == null ||
        transaction['date'].toString().trim().isEmpty) {
      errors.add('Date is required');
    } else {
      try {
        DateTime.parse(transaction['date'].toString());
      } catch (e) {
        errors.add('Invalid date format');
      }
    }

    if (transaction['type'] == null ||
        transaction['type'].toString().trim().isEmpty) {
      errors.add('Transaction type is required');
    } else {
      final type = transaction['type'].toString().toLowerCase();
      if (type != 'income' && type != 'expense') {
        errors.add('Transaction type must be either "income" or "expense"');
      }
    }

    // Optional fields validation
    if (transaction['remark'] != null &&
        transaction['remark'].toString().length > 500) {
      errors.add('Remark cannot exceed 500 characters');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate budget data
  static ValidationResult validateBudget(Map<String, dynamic> budget) {
    final errors = <String>[];

    if (budget['type'] == null || budget['type'].toString().trim().isEmpty) {
      errors.add('Budget type is required');
    } else {
      final type = budget['type'].toString().toLowerCase();
      if (!['weekly', 'monthly', 'yearly'].contains(type)) {
        errors.add('Budget type must be weekly, monthly, or yearly');
      }
    }

    if (budget['amount'] == null) {
      errors.add('Budget amount is required');
    } else {
      final amount = double.tryParse(budget['amount'].toString());
      if (amount == null) {
        errors.add('Budget amount must be a valid number');
      } else if (amount <= 0) {
        errors.add('Budget amount must be greater than 0');
      } else if (amount > 10000000) {
        errors.add('Budget amount cannot exceed 10,000,000');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate financial goal data
  static ValidationResult validateFinancialGoal(Map<String, dynamic> goal) {
    final errors = <String>[];

    if (goal['title'] == null || goal['title'].toString().trim().isEmpty) {
      errors.add('Goal title is required');
    } else if (goal['title'].toString().length > 100) {
      errors.add('Goal title cannot exceed 100 characters');
    }

    if (goal['target_amount'] == null) {
      errors.add('Target amount is required');
    } else {
      final amount = double.tryParse(goal['target_amount'].toString());
      if (amount == null) {
        errors.add('Target amount must be a valid number');
      } else if (amount <= 0) {
        errors.add('Target amount must be greater than 0');
      } else if (amount > 10000000) {
        errors.add('Target amount cannot exceed 10,000,000');
      }
    }

    if (goal['current_amount'] != null) {
      final currentAmount = double.tryParse(goal['current_amount'].toString());
      if (currentAmount == null) {
        errors.add('Current amount must be a valid number');
      } else if (currentAmount < 0) {
        errors.add('Current amount cannot be negative');
      }
    }

    if (goal['target_date'] != null &&
        goal['target_date'].toString().trim().isNotEmpty) {
      try {
        final targetDate = DateTime.parse(goal['target_date'].toString());
        if (targetDate.isBefore(DateTime.now())) {
          errors.add('Target date cannot be in the past');
        }
      } catch (e) {
        errors.add('Invalid target date format');
      }
    }

    if (goal['priority'] != null) {
      final priority = int.tryParse(goal['priority'].toString());
      if (priority == null) {
        errors.add('Priority must be a valid number');
      } else if (priority < 1 || priority > 5) {
        errors.add('Priority must be between 1 and 5');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate investment data
  static ValidationResult validateInvestment(Map<String, dynamic> investment) {
    final errors = <String>[];

    if (investment['name'] == null ||
        investment['name'].toString().trim().isEmpty) {
      errors.add('Investment name is required');
    } else if (investment['name'].toString().length > 100) {
      errors.add('Investment name cannot exceed 100 characters');
    }

    if (investment['type'] == null ||
        investment['type'].toString().trim().isEmpty) {
      errors.add('Investment type is required');
    } else {
      final type = investment['type'].toString().toLowerCase();
      if (![
        'stock',
        'bond',
        'mutual_fund',
        'crypto',
        'etf',
        'commodity',
      ].contains(type)) {
        errors.add('Invalid investment type');
      }
    }

    if (investment['quantity'] == null) {
      errors.add('Quantity is required');
    } else {
      final quantity = double.tryParse(investment['quantity'].toString());
      if (quantity == null) {
        errors.add('Quantity must be a valid number');
      } else if (quantity <= 0) {
        errors.add('Quantity must be greater than 0');
      }
    }

    if (investment['purchase_price'] == null) {
      errors.add('Purchase price is required');
    } else {
      final price = double.tryParse(investment['purchase_price'].toString());
      if (price == null) {
        errors.add('Purchase price must be a valid number');
      } else if (price <= 0) {
        errors.add('Purchase price must be greater than 0');
      }
    }

    if (investment['purchase_date'] == null ||
        investment['purchase_date'].toString().trim().isEmpty) {
      errors.add('Purchase date is required');
    } else {
      try {
        DateTime.parse(investment['purchase_date'].toString());
      } catch (e) {
        errors.add('Invalid purchase date format');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate emergency fund data
  static ValidationResult validateEmergencyFund(
    Map<String, dynamic> emergencyFund,
  ) {
    final errors = <String>[];

    if (emergencyFund['name'] == null ||
        emergencyFund['name'].toString().trim().isEmpty) {
      errors.add('Emergency fund name is required');
    } else if (emergencyFund['name'].toString().length > 100) {
      errors.add('Emergency fund name cannot exceed 100 characters');
    }

    if (emergencyFund['target_amount'] == null) {
      errors.add('Target amount is required');
    } else {
      final amount = double.tryParse(emergencyFund['target_amount'].toString());
      if (amount == null) {
        errors.add('Target amount must be a valid number');
      } else if (amount <= 0) {
        errors.add('Target amount must be greater than 0');
      } else if (amount > 10000000) {
        errors.add('Target amount cannot exceed 10,000,000');
      }
    }

    if (emergencyFund['current_amount'] != null) {
      final currentAmount = double.tryParse(
        emergencyFund['current_amount'].toString(),
      );
      if (currentAmount == null) {
        errors.add('Current amount must be a valid number');
      } else if (currentAmount < 0) {
        errors.add('Current amount cannot be negative');
      }
    }

    if (emergencyFund['priority'] != null) {
      final priority = int.tryParse(emergencyFund['priority'].toString());
      if (priority == null) {
        errors.add('Priority must be a valid number');
      } else if (priority < 1 || priority > 5) {
        errors.add('Priority must be between 1 and 5');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate recurring transaction data
  static ValidationResult validateRecurringTransaction(
    Map<String, dynamic> recurring,
  ) {
    final errors = <String>[];

    if (recurring['title'] == null ||
        recurring['title'].toString().trim().isEmpty) {
      errors.add('Title is required');
    } else if (recurring['title'].toString().length > 100) {
      errors.add('Title cannot exceed 100 characters');
    }

    if (recurring['amount'] == null) {
      errors.add('Amount is required');
    } else {
      final amount = double.tryParse(recurring['amount'].toString());
      if (amount == null) {
        errors.add('Amount must be a valid number');
      } else if (amount <= 0) {
        errors.add('Amount must be greater than 0');
      }
    }

    if (recurring['category'] == null ||
        recurring['category'].toString().trim().isEmpty) {
      errors.add('Category is required');
    }

    if (recurring['frequency'] == null ||
        recurring['frequency'].toString().trim().isEmpty) {
      errors.add('Frequency is required');
    } else {
      final frequency = recurring['frequency'].toString().toLowerCase();
      if (!['daily', 'weekly', 'monthly', 'yearly'].contains(frequency)) {
        errors.add('Frequency must be daily, weekly, monthly, or yearly');
      }
    }

    if (recurring['next_due_date'] == null ||
        recurring['next_due_date'].toString().trim().isEmpty) {
      errors.add('Next due date is required');
    } else {
      try {
        DateTime.parse(recurring['next_due_date'].toString());
      } catch (e) {
        errors.add('Invalid next due date format');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate user data
  static ValidationResult validateUser(Map<String, dynamic> user) {
    final errors = <String>[];

    if (user['email'] == null || user['email'].toString().trim().isEmpty) {
      errors.add('Email is required');
    } else {
      final email = user['email'].toString().trim();
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        errors.add('Invalid email format');
      }
    }

    if (user['name'] == null || user['name'].toString().trim().isEmpty) {
      errors.add('Name is required');
    } else if (user['name'].toString().length > 100) {
      errors.add('Name cannot exceed 100 characters');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate amount input
  static ValidationResult validateAmount(String amount) {
    final errors = <String>[];

    if (amount.trim().isEmpty) {
      errors.add('Amount is required');
    } else {
      final parsedAmount = double.tryParse(amount);
      if (parsedAmount == null) {
        errors.add('Amount must be a valid number');
      } else if (parsedAmount <= 0) {
        errors.add('Amount must be greater than 0');
      } else if (parsedAmount > 1000000) {
        errors.add('Amount cannot exceed 1,000,000');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate date input
  static ValidationResult validateDate(String date) {
    final errors = <String>[];

    if (date.trim().isEmpty) {
      errors.add('Date is required');
    } else {
      try {
        final parsedDate = DateTime.parse(date);
        if (parsedDate.isAfter(DateTime.now().add(Duration(days: 365)))) {
          errors.add('Date cannot be more than 1 year in the future');
        }
      } catch (e) {
        errors.add('Invalid date format');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Show validation errors in a user-friendly way
  static void showValidationErrors(
    BuildContext context,
    ValidationResult result,
  ) {
    if (!result.isValid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Validation Errors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: result.errors.map((error) => Text('• $error')).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});
}
