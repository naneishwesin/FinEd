// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/database_service.dart';
import '../services/hybrid_data_service.dart';
import '../services/notification_service.dart';
import '../services/tutorial_service.dart';
import '../utils/page_transitions.dart';
import 'bookmarks_page.dart';
import 'budget_management_page.dart';
import 'categories_management_page.dart';
import 'notification_settings_page.dart';
import 'qr_share_page.dart';
import 'tutorial_guide_page.dart';

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;

  const SettingsPage({super.key, this.onThemeChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _selectedLanguage = "English";
  int _monthlyStartDate = 1;
  String _selectedCurrency = "Thai Baht (฿)";
  bool _alarmEnabled = true;
  TimeOfDay _alarmTime = const TimeOfDay(hour: 9, minute: 0);
  bool _spendingAlerts = true;
  bool _goalReminders = false;
  bool _budgetAlerts = false;
  String _appVersion = "1.0.0"; // Add app version state

  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
    _showTutorials();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      debugPrint('Error loading app version: $e');
    }
  }

  void _showTutorials() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSettingsPageTutorial();
    });
  }

  void _showSettingsPageTutorial() {
    if (!TutorialService.isTutorialCompleted(
      TutorialService.settingsPageProfile,
    )) {
      TutorialService.showTutorial(
        context,
        TutorialService.settingsPageProfile,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Settings & Customization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Here you can:\n'
              '• Edit your profile information\n'
              '• Customize app appearance\n'
              '• Manage notifications and alerts\n'
              '• Organize categories and bookmarks\n'
              '• Configure language and currency',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  // User Profile Data
  String _fullName = "nan ei";
  DateTime _dateOfBirth = DateTime(2002, 4, 21);
  String _university = "Assumption University";
  double _monthlyAllowance = 20000;
  double _warningAmount = 5000;

  final List<String> _languages = ["English", "ไทย", "中文", "日本語"];
  final List<String> _currencies = [
    "Thai Baht (฿)",
    "US Dollar (\$)",
    "Euro (€)",
    "Japanese Yen (¥)",
    "Chinese Yuan (¥)",
  ];

  Future<void> _loadSettings() async {
    try {
      // Load settings from database with proper type handling
      final themeString =
          await _dbService.getSetting<String>('theme') ?? 'light';
      final isDarkMode = themeString == 'dark';

      final alarmEnabledString =
          await _dbService.getSetting<String>('daily_reminder') ?? 'true';
      final alarmEnabled = alarmEnabledString == 'true';

      final monthlyStartDateString =
          await _dbService.getSetting<String>('monthly_start_date') ?? '1';
      final monthlyStartDate = int.tryParse(monthlyStartDateString) ?? 1;

      final selectedLanguage =
          await _dbService.getSetting<String>('language') ?? 'English';
      final selectedCurrency =
          await _dbService.getSetting<String>('currency') ?? 'Thai Baht (฿)';

      final spendingAlertsString =
          await _dbService.getSetting<String>('spending_alerts') ?? 'true';
      final spendingAlerts = spendingAlertsString == 'true';

      final goalRemindersString =
          await _dbService.getSetting<String>('goal_reminders') ?? 'false';
      final goalReminders = goalRemindersString == 'false';

      final budgetAlertsString =
          await _dbService.getSetting<String>('budget_alerts') ?? 'false';
      final budgetAlerts = budgetAlertsString == 'false';

      // Load profile from database
      final fullName =
          await _dbService.getSetting<String>('full_name') ?? 'nan ei';
      final university =
          await _dbService.getSetting<String>('university') ??
          'Assumption University';

      final monthlyAllowanceString =
          await _dbService.getSetting<String>('monthly_allowance') ?? '20000.0';
      final monthlyAllowance =
          double.tryParse(monthlyAllowanceString) ?? 20000.0;

      final warningAmountString =
          await _dbService.getSetting<String>('warning_amount') ?? '5000.0';
      final warningAmount = double.tryParse(warningAmountString) ?? 5000.0;

      final dateOfBirthString = await _dbService.getSetting<String>(
        'date_of_birth',
      );

      setState(() {
        // App Settings
        _isDarkMode = isDarkMode;
        _alarmEnabled = alarmEnabled;
        _monthlyStartDate = monthlyStartDate;
        _selectedLanguage = selectedLanguage;
        _selectedCurrency = selectedCurrency;

        // Alert Settings
        _spendingAlerts = spendingAlerts;
        _goalReminders = goalReminders;
        _budgetAlerts = budgetAlerts;

        // User Profile
        _fullName = fullName;
        _university = university;
        _monthlyAllowance = monthlyAllowance;
        _warningAmount = warningAmount;

        if (dateOfBirthString != null) {
          try {
            _dateOfBirth = DateTime.parse(dateOfBirthString);
          } catch (e) {
            print('Error parsing date of birth: $e');
            _dateOfBirth = DateTime(2002, 4, 21); // Default date
          }
        }
      });
    } catch (e) {
      print('Error loading settings from database: $e');
      // Use default values if database fails
      setState(() {
        // Keep current default values - they're already set in the variable declarations
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      // Save settings to database as strings
      await _dbService.setSetting('theme', _isDarkMode ? 'dark' : 'light');
      await _dbService.setSetting('language', _selectedLanguage);
      await _dbService.setSetting('currency', _selectedCurrency);
      await _dbService.setSetting(
        'monthly_start_date',
        _monthlyStartDate.toString(),
      );
      await _dbService.setSetting('daily_reminder', _alarmEnabled.toString());
      await _dbService.setSetting(
        'spending_alerts',
        _spendingAlerts.toString(),
      );
      await _dbService.setSetting('goal_reminders', _goalReminders.toString());
      await _dbService.setSetting('budget_alerts', _budgetAlerts.toString());

      // Save profile settings to database
      await _dbService.setSetting('full_name', _fullName);
      await _dbService.setSetting('university', _university);
      await _dbService.setSetting(
        'monthly_allowance',
        _monthlyAllowance.toString(),
      );
      await _dbService.setSetting('warning_amount', _warningAmount.toString());
      await _dbService.setSetting(
        'date_of_birth',
        _dateOfBirth.toIso8601String(),
      );
    } catch (e) {
      print('Error saving settings to database: $e');
      // Settings save failed, but app continues to work
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("⚙️ Settings"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 User Profile Section
            _buildUserProfileCard(),

            const SizedBox(height: 20),

            // 🎨 Custom Section
            _buildSectionCard("Custom", Icons.palette, [
              _buildSwitchTile(
                "Dark/Light Theme",
                Icons.dark_mode,
                _isDarkMode,
                (value) async {
                  setState(() {
                    _isDarkMode = value;
                  });

                  final newThemeMode = value ? ThemeMode.dark : ThemeMode.light;

                  // Apply theme change immediately
                  if (widget.onThemeChanged != null) {
                    widget.onThemeChanged!(newThemeMode);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Theme switched to ${value ? 'Dark' : 'Light'} mode",
                      ),
                      backgroundColor: Colors.blue[600],
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  await _saveSettings();
                },
              ),
              _buildListTile(
                "Switch Language",
                Icons.language,
                _selectedLanguage,
                () => _showLanguageDialog(),
              ),
              _buildListTile(
                "Monthly Start Date",
                Icons.calendar_today,
                "Day $_monthlyStartDate",
                () => _showDateDialog(),
              ),
              _buildListTile(
                "Current Symbol",
                Icons.attach_money,
                _selectedCurrency,
                () => _showCurrencyDialog(),
              ),
              _buildSwitchTile("Daily Reminder", Icons.alarm, _alarmEnabled, (
                value,
              ) async {
                setState(() {
                  _alarmEnabled = value;
                });

                // Schedule or cancel daily reminder
                if (value) {
                  await NotificationService.scheduleDailyReminder(_alarmTime);
                } else {
                  await NotificationService.cancelDailyReminder();
                }

                await _saveSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Daily reminder ${value ? 'enabled' : 'disabled'}",
                    ),
                    backgroundColor: Colors.blue[600],
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }),
              if (_alarmEnabled)
                _buildListTile(
                  "Reminder Time",
                  Icons.access_time,
                  _alarmTime.format(context),
                  () => _showTimeDialog(),
                ),
            ]),

            const SizedBox(height: 20),

            // 🔔 Alerts Section
            _buildSectionCard("Alerts & Notifications", Icons.notifications, [
              _buildSwitchTile(
                "Spending Alerts",
                Icons.warning,
                _spendingAlerts,
                (value) async {
                  setState(() {
                    _spendingAlerts = value;
                  });
                  await _saveSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Spending alerts ${value ? 'enabled' : 'disabled'}",
                      ),
                      backgroundColor: Colors.blue[600],
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildSwitchTile("Goal Reminders", Icons.flag, _goalReminders, (
                value,
              ) async {
                setState(() {
                  _goalReminders = value;
                });
                await _saveSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Goal reminders ${value ? 'enabled' : 'disabled'}",
                    ),
                    backgroundColor: Colors.blue[600],
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }),
              _buildSwitchTile(
                "Budget Alerts",
                Icons.account_balance_wallet,
                _budgetAlerts,
                (value) async {
                  setState(() {
                    _budgetAlerts = value;
                  });
                  await _saveSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Budget alerts ${value ? 'enabled' : 'disabled'}",
                      ),
                      backgroundColor: Colors.blue[600],
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // 📊 Management Section
            _buildSectionCard("Management", Icons.settings, [
              _buildNavigationTile(
                "Record Category Management",
                Icons.category,
                () {
                  AnimatedNavigation.slideFromRight(
                    context,
                    CategoriesManagementPage(),
                  );
                },
              ),
              _buildNavigationTile("Bookmarks", Icons.bookmark, () {
                AnimatedNavigation.slideFromRight(context, BookmarksPage());
              }),
              _buildNavigationTile(
                "Budget Management",
                Icons.account_balance_wallet,
                () {
                  AnimatedNavigation.slideFromRight(
                    context,
                    BudgetManagementPage(),
                  );
                },
              ),
              _buildNavigationTile(
                "Notification Settings",
                Icons.notifications,
                () {
                  AnimatedNavigation.slideFromRight(
                    context,
                    NotificationSettingsPage(),
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // ℹ️ About Us Section
            _buildSectionCard("About Us", Icons.info, [
              _buildNavigationTile(
                "App Version",
                Icons.info_outline,
                () {},
                trailing: Text(_appVersion),
              ),
              _buildNavigationTile(
                "App Tutorial",
                Icons.school,
                () => AnimatedNavigation.slideFromRight(
                  context,
                  TutorialGuidePage(),
                ),
                trailing: const Text("Guide"),
              ),
              _buildNavigationTile(
                "Share App",
                Icons.qr_code,
                () => AnimatedNavigation.slideFromRight(context, QRSharePage()),
                trailing: const Text("QR Code"),
              ),
              _buildNavigationTile(
                "Reset Tutorials",
                Icons.refresh,
                () => _showResetTutorialsDialog(),
                trailing: const Text("Help"),
              ),
              _buildNavigationTile(
                "Reset Welcome Page",
                Icons.home,
                () => _showResetOnboardingDialog(),
                trailing: const Text("Reset"),
              ),
              _buildNavigationTile(
                "Privacy Policy",
                Icons.privacy_tip,
                () => _showComingSoon("Privacy Policy"),
              ),
              _buildNavigationTile(
                "Terms of Service",
                Icons.description,
                () => _showComingSoon("Terms of Service"),
              ),
              _buildNavigationTile(
                "Contact Us",
                Icons.contact_support,
                () => _showContactDialog(),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return GestureDetector(
      onTap: () => _showEditProfileDialog(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Profile Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(Icons.person, size: 30, color: Colors.blue[600]),
                ),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "nan.ei@student.chula.ac.th",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Premium Member",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit Button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Accounts", "3"),
                _buildStatItem("Categories", "12"),
                _buildStatItem("Budgets", "5"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildNavigationTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((language) {
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (String? value) async {
                  setState(() {
                    _selectedLanguage = value ?? "English";
                  });
                  await _saveSettings();
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Language changed to $_selectedLanguage. Restart the app to see changes.",
                      ),
                      backgroundColor: Colors.blue[600],
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showDateDialog() {
    final TextEditingController dateController = TextEditingController(
      text: _monthlyStartDate.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Input the start date (btw 1 to 31)"),
          content: TextField(
            controller: dateController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "Enter day (1-31)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue[600]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final inputValue = int.tryParse(dateController.text);
                if (inputValue != null && inputValue >= 1 && inputValue <= 31) {
                  setState(() {
                    _monthlyStartDate = inputValue;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Monthly start date set to day $inputValue",
                      ),
                      backgroundColor: Colors.blue[600],
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please enter a valid date between 1 and 31",
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Currency"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _currencies.map((currency) {
              return RadioListTile<String>(
                title: Text(currency),
                value: currency,
                groupValue: _selectedCurrency,
                onChanged: (String? value) async {
                  setState(() {
                    _selectedCurrency = value ?? "Thai Baht (฿)";
                  });
                  await _saveSettings();
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Currency changed to $_selectedCurrency. Restart the app to see changes.",
                      ),
                      backgroundColor: Colors.blue[600],
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showTimeDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _alarmTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _alarmTime) {
      setState(() {
        _alarmTime = picked;
      });
    }
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contact Us"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email: support@expensetracker.com"),
              SizedBox(height: 8),
              Text("Phone: +66 123 456 789"),
              SizedBox(height: 8),
              Text("Website: www.expensetracker.com"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$feature - Coming Soon!"),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showResetTutorialsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Tutorials"),
        content: const Text(
          "This will reset all tutorial completion status and show tutorials again when you navigate to different pages. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await TutorialService.resetAllTutorials();
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Tutorials reset! Navigate to pages to see tutorials again.",
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  void _showResetOnboardingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Welcome Page"),
        content: const Text(
          "This will reset the onboarding status and show the welcome page again when you restart the app. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await HybridDataService.resetOnboardingStatus();
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Welcome page reset! Restart the app to see the welcome page again.",
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final TextEditingController fullNameController = TextEditingController(
      text: _fullName,
    );
    final TextEditingController universityController = TextEditingController(
      text: _university,
    );
    final TextEditingController monthlyAllowanceController =
        TextEditingController(text: _monthlyAllowance.toString());
    final TextEditingController warningAmountController = TextEditingController(
      text: _warningAmount.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Profile"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildFormField("Full Name", fullNameController),
                    const SizedBox(height: 16),

                    // Date of Birth
                    _buildDateField(),
                    const SizedBox(height: 16),

                    // University
                    _buildFormField(
                      "University",
                      universityController,
                      hintText: "Enter your university",
                    ),
                    const SizedBox(height: 16),

                    // Monthly Allowance
                    _buildNumberField(
                      "Monthly Allowance",
                      monthlyAllowanceController,
                    ),
                    const SizedBox(height: 16),

                    // Warning Amount
                    _buildNumberField(
                      "Warning Amount (Alert when expenses exceed this)",
                      warningAmountController,
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                // Save Profile Button (Primary Action)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _saveProfileData(
                        fullNameController.text,
                        universityController.text,
                        monthlyAllowanceController.text,
                        warningAmountController.text,
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Save Profile",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary Actions Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Delete Profile Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => _showDeleteProfileDialog(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.red[300]!),
                          ),
                        ),
                        child: const Text(
                          "Delete Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date of Birth",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _dateOfBirth,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != _dateOfBirth) {
              setState(() {
                _dateOfBirth = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  "${_dateOfBirth.day.toString().padLeft(2, '0')}/${_dateOfBirth.month.toString().padLeft(2, '0')}/${_dateOfBirth.year}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            // Add thousand separator formatting
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_money, color: Colors.grey[600], size: 20),
                Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 60),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfileData(
    String fullName,
    String university,
    String monthlyAllowance,
    String warningAmount,
  ) async {
    // Validation
    if (fullName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your full name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final monthlyAmount = double.tryParse(monthlyAllowance);
    if (monthlyAmount == null || monthlyAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid monthly allowance"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final warningAmountValue = double.tryParse(warningAmount);
    if (warningAmountValue == null || warningAmountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid warning amount"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _fullName = fullName.trim();
      _university = university.trim();
      _monthlyAllowance = monthlyAmount;
      _warningAmount = warningAmountValue;
    });

    final profile = {
      'name': _fullName,
      'university': _university,
      'monthly_allowance': _monthlyAllowance,
      'warning_amount': _warningAmount,
      'date_of_birth': _dateOfBirth.toIso8601String(),
    };

    await HybridDataService.saveUserProfile(profile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile saved successfully!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Profile"),
          content: const Text(
            "Are you sure you want to delete your profile? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile deleted successfully"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete Profile"),
            ),
          ],
        );
      },
    );
  }
}
