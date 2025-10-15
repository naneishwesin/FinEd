// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  // Initialize notifications
  static Future<void> init() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Request permissions
    await _requestPermissions();
    _isInitialized = true;
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      print('Notification permission request failed: $e');
      // Continue without notifications
    }
  }

  // Schedule daily reminder
  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily expense tracking reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // For now, show immediate notification
    await _notifications.show(
      0,
      'Daily Expense Reminder',
      'Don\'t forget to track your expenses today!',
      details,
    );
  }

  // Cancel daily reminder
  static Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }

  // Schedule budget alert
  static Future<void> scheduleBudgetAlert(
    String budgetName,
    double budgetAmount,
    double spentAmount,
    double threshold,
  ) async {
    final remaining = budgetAmount - spentAmount;
    final percentage = (spentAmount / budgetAmount) * 100;

    String title;
    String body;

    if (percentage >= 100) {
      title = 'Budget Exceeded!';
      body =
          'You have exceeded your $budgetName budget by ${(percentage - 100).toStringAsFixed(1)}%';
    } else if (percentage >= threshold) {
      title = 'Budget Warning';
      body =
          'You\'ve used ${percentage.toStringAsFixed(1)}% of your $budgetName budget. Only ฿${remaining.toStringAsFixed(2)} remaining.';
    } else {
      return; // Don't send notification if below threshold
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription: 'Budget and spending alerts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // Schedule goal progress notification
  static Future<void> scheduleGoalProgressNotification(
    String goalName,
    double currentAmount,
    double targetAmount,
    double progress,
  ) async {
    String title = 'Goal Progress Update';
    String body;

    if (progress >= 100) {
      body = 'Congratulations! You\'ve achieved your $goalName goal!';
    } else if (progress >= 75) {
      body =
          'You\'re almost there! $goalName is ${progress.toStringAsFixed(1)}% complete.';
    } else if (progress >= 50) {
      body =
          'Great progress! $goalName is ${progress.toStringAsFixed(1)}% complete.';
    } else {
      body =
          'Keep going! $goalName is ${progress.toStringAsFixed(1)}% complete.';
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'goal_progress',
          'Goal Progress',
          channelDescription: 'Financial goal progress updates',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // Schedule low balance alert
  static Future<void> scheduleLowBalanceAlert(double currentBalance) async {
    String title = 'Low Balance Alert';
    String body =
        'Your current balance is ฿${currentBalance.toStringAsFixed(2)}. Consider reviewing your spending.';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'balance_alerts',
          'Balance Alerts',
          channelDescription: 'Low balance and spending alerts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // Schedule spending pattern alert
  static Future<void> scheduleSpendingPatternAlert() async {
    // This would typically analyze spending patterns from your data
    // For now, we'll send a generic reminder

    String title = 'Weekly Spending Review';
    String body =
        'Review your spending patterns from the past week to stay on track with your budget.';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'spending_review',
          'Spending Review',
          channelDescription: 'Weekly spending pattern reviews',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Check budget alerts
  static Future<void> checkBudgetAlerts() async {
    final budgets = await DatabaseService().getAllBudgets();
    for (final budget in budgets) {
      final budgetAmount = budget['amount'] as double;
      final spentAmount = budget['spent'] as double? ?? 0.0;
      final threshold = budget['threshold'] as double? ?? 80.0;
      final budgetName = budget['name'] as String;

      if (spentAmount > 0) {
        await scheduleBudgetAlert(
          budgetName,
          budgetAmount,
          spentAmount,
          threshold,
        );
      }
    }
  }

  // Check goal progress
  static Future<void> checkGoalProgress() async {
    // TODO: Implement financial goals from database
    final goals = <Map<String, dynamic>>[];
    for (final goal in goals) {
      final targetAmount = goal['targetAmount'] as double;
      final currentAmount = goal['currentAmount'] as double? ?? 0.0;
      final goalName = goal['name'] as String;
      final progress = (currentAmount / targetAmount) * 100;

      if (currentAmount > 0) {
        await scheduleGoalProgressNotification(
          goalName,
          currentAmount,
          targetAmount,
          progress,
        );
      }
    }
  }

  // Check low balance
  static Future<void> checkLowBalance() async {
    final balance = await DatabaseService().getCurrentBalance();
    if (balance < 1000) {
      // Alert if balance is below ฿1000
      await scheduleLowBalanceAlert(balance);
    }
  }

  // Schedule weekly review
  static Future<void> scheduleWeeklyReview() async {
    await scheduleSpendingPatternAlert();
  }

  // Show test notification
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Test Notification',
      'This is a test notification from Expense Tracker',
      details,
    );
  }

  // Enable/disable notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool('notifications_enabled', enabled);
    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  static bool areNotificationsEnabled() {
    return _prefs?.getBool('notifications_enabled') ?? true;
  }

  static Map<String, dynamic> getNotificationSettings() {
    return {
      'daily_reminder': _prefs?.getBool('daily_reminder') ?? true,
      'budget_alerts': _prefs?.getBool('budget_alerts') ?? true,
      'goal_reminders': _prefs?.getBool('goal_reminders') ?? true,
      'balance_alerts': _prefs?.getBool('balance_alerts') ?? true,
      'spending_review': _prefs?.getBool('spending_review') ?? false,
    };
  }

  static Future<void> setNotificationSettings(
    Map<String, bool> settings,
  ) async {
    for (final entry in settings.entries) {
      await _prefs?.setBool(entry.key, entry.value);
    }
  }

  // Helper method to get next instance of time
  static DateTime _nextInstanceOfTime(TimeOfDay time) {
    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
