// lib/services/enhanced_error_handler.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedErrorHandler {
  static final EnhancedErrorHandler _instance =
      EnhancedErrorHandler._internal();
  factory EnhancedErrorHandler() => _instance;
  EnhancedErrorHandler._internal();

  // Error types
  static const String networkError = 'network_error';
  static const String databaseError = 'database_error';
  static const String validationError = 'validation_error';
  static const String authenticationError = 'authentication_error';
  static const String syncError = 'sync_error';
  static const String unknownError = 'unknown_error';

  // Show error with proper categorization
  static void showError(BuildContext context, String message, {String? type}) {
    HapticFeedback.heavyImpact();

    final errorType = type ?? unknownError;
    final errorColor = _getErrorColor(errorType);
    final errorIcon = _getErrorIcon(errorType);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(errorIcon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success message
  static void showSuccess(BuildContext context, String message) {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show warning message
  static void showWarning(BuildContext context, String message) {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Show info message
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show loading dialog
  static void showLoading(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Handle API errors
  static String handleApiError(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Network connection failed. Please check your internet connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('unauthorized')) {
      return 'Authentication failed. Please sign in again.';
    } else if (error.toString().contains('not found')) {
      return 'Resource not found.';
    } else if (error.toString().contains('server')) {
      return 'Server error. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Handle database errors
  static String handleDatabaseError(dynamic error) {
    if (error.toString().contains('constraint')) {
      return 'Data validation failed. Please check your input.';
    } else if (error.toString().contains('unique')) {
      return 'This data already exists.';
    } else if (error.toString().contains('foreign key')) {
      return 'Cannot delete this item as it is being used elsewhere.';
    } else {
      return 'Database operation failed. Please try again.';
    }
  }

  // Handle validation errors
  static String handleValidationError(dynamic error) {
    return 'Please check your input and try again.';
  }

  // Get error color based on type
  static Color _getErrorColor(String type) {
    switch (type) {
      case networkError:
        return Colors.orange;
      case databaseError:
        return Colors.red;
      case validationError:
        return Colors.amber;
      case authenticationError:
        return Colors.purple;
      case syncError:
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  // Get error icon based on type
  static IconData _getErrorIcon(String type) {
    switch (type) {
      case networkError:
        return Icons.wifi_off;
      case databaseError:
        return Icons.storage;
      case validationError:
        return Icons.warning;
      case authenticationError:
        return Icons.lock;
      case syncError:
        return Icons.sync_problem;
      default:
        return Icons.error;
    }
  }

  // Log error for debugging
  static void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    debugPrint('ERROR: $message');
    if (error != null) {
      debugPrint('Error details: $error');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Global error handler
  static void setupGlobalErrorHandler() {
    FlutterError.onError = (FlutterErrorDetails details) {
      logError(
        'Flutter Error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      logError('Platform Error', error: error, stackTrace: stack);
      return true;
    };
  }
}
