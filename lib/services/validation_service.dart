// lib/services/validation_service.dart
import 'package:flutter/material.dart';

class ValidationService {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 999999) {
      return 'Amount is too large';
    }
    return null;
  }

  // Category validation
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // University validation
  static String? validateUniversity(String? value) {
    if (value == null || value.isEmpty) {
      return 'University is required';
    }
    return null;
  }

  // Monthly allowance validation
  static String? validateMonthlyAllowance(String? value) {
    if (value == null || value.isEmpty) {
      return 'Monthly allowance is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  // Warning amount validation
  static String? validateWarningAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Warning amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  // Investment name validation
  static String? validateInvestmentName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Investment name is required';
    }
    if (value.length < 2) {
      return 'Investment name must be at least 2 characters';
    }
    return null;
  }

  // Emergency fund amount validation
  static String? validateEmergencyFundAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Emergency fund amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'Date cannot be in the future';
    }
    return null;
  }

  // Time validation
  static String? validateTime(TimeOfDay? value) {
    if (value == null) {
      return 'Time is required';
    }
    return null;
  }

  // Form validation helper
  static bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  // Save form helper
  static void saveForm(GlobalKey<FormState> formKey) {
    formKey.currentState?.save();
  }

  // Reset form helper
  static void resetForm(GlobalKey<FormState> formKey) {
    formKey.currentState?.reset();
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Show error message helper
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show success message helper
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show validation error helper
  static void showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
