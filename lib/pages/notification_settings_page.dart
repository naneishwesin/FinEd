// lib/pages/notification_settings_page.dart
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  Map<String, bool> _notificationSettings = {};
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationSettings = Map<String, bool>.from(
        NotificationService.getNotificationSettings(),
      );
      _notificationsEnabled = NotificationService.areNotificationsEnabled();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notification Settings"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enable/Disable Notifications
            _buildSectionCard("General", Icons.notifications, [
              _buildSwitchTile(
                "Enable Notifications",
                "Allow the app to send you notifications",
                _notificationsEnabled,
                (value) async {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  await NotificationService.setNotificationsEnabled(value);
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Daily Reminder
            _buildSectionCard("Daily Reminders", Icons.schedule, [
              _buildListTile(
                "Daily Reminder Time",
                _formatTime(_dailyReminderTime),
                Icons.access_time,
                () => _selectTime(),
              ),
              _buildSwitchTile(
                "Daily Expense Reminder",
                "Remind me to track my expenses daily",
                _notificationSettings['daily_reminder'] ?? true,
                (value) async {
                  setState(() {
                    _notificationSettings['daily_reminder'] = value;
                  });
                  await NotificationService.setNotificationSettings(
                    _notificationSettings,
                  );
                  if (value) {
                    await NotificationService.scheduleDailyReminder(
                      _dailyReminderTime,
                    );
                  } else {
                    await NotificationService.cancelNotification(0);
                  }
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Budget Alerts
            _buildSectionCard("Budget Alerts", Icons.account_balance_wallet, [
              _buildSwitchTile(
                "Budget Limit Alerts",
                "Notify when approaching or exceeding budget limits",
                _notificationSettings['budget_alerts'] ?? true,
                (value) async {
                  setState(() {
                    _notificationSettings['budget_alerts'] = value;
                  });
                  await NotificationService.setNotificationSettings(
                    _notificationSettings,
                  );
                },
              ),
              _buildSwitchTile(
                "Low Balance Alerts",
                "Notify when your balance is running low",
                _notificationSettings['balance_alerts'] ?? true,
                (value) async {
                  setState(() {
                    _notificationSettings['balance_alerts'] = value;
                  });
                  await NotificationService.setNotificationSettings(
                    _notificationSettings,
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Goal Reminders
            _buildSectionCard("Goal Reminders", Icons.flag, [
              _buildSwitchTile(
                "Goal Progress Updates",
                "Notify about financial goal milestones",
                _notificationSettings['goal_reminders'] ?? true,
                (value) async {
                  setState(() {
                    _notificationSettings['goal_reminders'] = value;
                  });
                  await NotificationService.setNotificationSettings(
                    _notificationSettings,
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Weekly Reviews
            _buildSectionCard("Weekly Reviews", Icons.analytics, [
              _buildSwitchTile(
                "Spending Pattern Alerts",
                "Weekly review of spending patterns",
                _notificationSettings['spending_review'] ?? false,
                (value) async {
                  setState(() {
                    _notificationSettings['spending_review'] = value;
                  });
                  await NotificationService.setNotificationSettings(
                    _notificationSettings,
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Test Notifications
            _buildSectionCard("Test Notifications", Icons.science, [
              _buildListTile(
                "Send Test Notification",
                "Test if notifications are working",
                Icons.send,
                () => _sendTestNotification(),
              ),
            ]),

            const SizedBox(height: 40),

            // Reset All Notifications
            Center(
              child: ElevatedButton(
                onPressed: () => _showResetDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Reset All Notifications"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue[600], size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: _notificationsEnabled ? onChanged : null,
        activeColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: _notificationsEnabled ? onTap : null,
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
    );

    if (picked != null && picked != _dailyReminderTime) {
      setState(() {
        _dailyReminderTime = picked;
      });

      if (_notificationSettings['daily_reminder'] == true) {
        await NotificationService.scheduleDailyReminder(_dailyReminderTime);
      }
    }
  }

  void _sendTestNotification() async {
    await NotificationService.showTestNotification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Notifications"),
        content: const Text(
          "This will reset all notification settings to default and cancel all scheduled notifications. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await NotificationService.cancelAllNotifications();
              await NotificationService.setNotificationsEnabled(true);
              setState(() {
                _notificationSettings = {
                  'daily_reminder': true,
                  'budget_alerts': true,
                  'goal_reminders': true,
                  'balance_alerts': true,
                  'spending_review': false,
                };
                _notificationsEnabled = true;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings reset successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reset", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
