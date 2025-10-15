// lib/services/hybrid_data_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_service.dart';

class HybridDataService {
  static SharedPreferences? _prefs;
  static bool _isOnline = false;

  // Initialize the service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isOnline = FirebaseService.isLoggedIn;
  }

  // Check if user is online
  static bool get isOnline => _isOnline && FirebaseService.isLoggedIn;

  // Set online status
  static void setOnlineStatus(bool online) {
    _isOnline = online;
  }

  // User Profile Data
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    if (isOnline) {
      try {
        await FirebaseService.saveUserProfile(profile);
        // Also save locally as backup
        await _prefs?.setString('user_profile', jsonEncode(profile));
      } catch (e) {
        // If online fails, save locally
        await _prefs?.setString('user_profile', jsonEncode(profile));
        throw Exception('Failed to sync online, saved locally: $e');
      }
    } else {
      await _prefs?.setString('user_profile', jsonEncode(profile));
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (isOnline) {
      try {
        final profile = await FirebaseService.getUserProfile();
        if (profile != null) {
          // Update local backup
          await _prefs?.setString('user_profile', jsonEncode(profile));
          return profile;
        }
      } catch (e) {
        // If online fails, try local
        print('Online fetch failed, trying local: $e');
      }
    }

    // Fallback to local data
    final profileString = _prefs?.getString('user_profile');
    if (profileString != null) {
      return jsonDecode(profileString);
    }
    return null;
  }

  // Financial Data
  static Future<void> saveFinancialData({
    required double currentBalance,
    required double totalIncome,
    required double totalExpenses,
  }) async {
    if (isOnline) {
      try {
        await FirebaseService.saveFinancialData(
          currentBalance: currentBalance,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
        );
        // Also save locally as backup
        await _prefs?.setDouble('current_balance', currentBalance);
        await _prefs?.setDouble('total_income', totalIncome);
        await _prefs?.setDouble('total_expenses', totalExpenses);
      } catch (e) {
        // If online fails, save locally
        await _prefs?.setDouble('current_balance', currentBalance);
        await _prefs?.setDouble('total_income', totalIncome);
        await _prefs?.setDouble('total_expenses', totalExpenses);
        throw Exception('Failed to sync online, saved locally: $e');
      }
    } else {
      await _prefs?.setDouble('current_balance', currentBalance);
      await _prefs?.setDouble('total_income', totalIncome);
      await _prefs?.setDouble('total_expenses', totalExpenses);
    }
  }

  static Future<Map<String, double>> getFinancialData() async {
    if (isOnline) {
      try {
        return await FirebaseService.getFinancialData();
      } catch (e) {
        print('Online fetch failed, trying local: $e');
      }
    }

    // Fallback to local data
    return {
      'currentBalance': _prefs?.getDouble('current_balance') ?? 0.0,
      'totalIncome': _prefs?.getDouble('total_income') ?? 0.0,
      'totalExpenses': _prefs?.getDouble('total_expenses') ?? 0.0,
    };
  }

  // Current Balance
  static Future<void> saveCurrentBalance(double balance) async {
    final financialData = await getFinancialData();
    await saveFinancialData(
      currentBalance: balance,
      totalIncome: financialData['totalIncome'] ?? 0.0,
      totalExpenses: financialData['totalExpenses'] ?? 0.0,
    );
  }

  static Future<double> getCurrentBalance() async {
    final financialData = await getFinancialData();
    return financialData['currentBalance'] ?? 0.0;
  }

  // Income and Expenses
  static Future<void> saveIncome(double income) async {
    final financialData = await getFinancialData();
    await saveFinancialData(
      currentBalance: financialData['currentBalance'] ?? 0.0,
      totalIncome: income,
      totalExpenses: financialData['totalExpenses'] ?? 0.0,
    );
  }

  static Future<double> getIncome() async {
    final financialData = await getFinancialData();
    return financialData['totalIncome'] ?? 0.0;
  }

  static Future<void> saveExpenses(double expenses) async {
    final financialData = await getFinancialData();
    await saveFinancialData(
      currentBalance: financialData['currentBalance'] ?? 0.0,
      totalIncome: financialData['totalIncome'] ?? 0.0,
      totalExpenses: expenses,
    );
  }

  static Future<double> getExpenses() async {
    final financialData = await getFinancialData();
    return financialData['totalExpenses'] ?? 0.0;
  }

  // Transactions
  static Future<void> saveTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    if (isOnline) {
      try {
        await FirebaseService.saveTransactions(transactions);
        // Also save locally as backup
        await _prefs?.setString('transactions', jsonEncode(transactions));
      } catch (e) {
        // If online fails, save locally
        await _prefs?.setString('transactions', jsonEncode(transactions));
        throw Exception('Failed to sync online, saved locally: $e');
      }
    } else {
      await _prefs?.setString('transactions', jsonEncode(transactions));
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    if (isOnline) {
      try {
        final transactions = await FirebaseService.getTransactions();
        // Update local backup
        await _prefs?.setString('transactions', jsonEncode(transactions));
        return transactions;
      } catch (e) {
        print('Online fetch failed, trying local: $e');
      }
    }

    // Fallback to local data
    final transactionsString = _prefs?.getString('transactions');
    if (transactionsString != null) {
      final List<dynamic> transactionsList = jsonDecode(transactionsString);
      return transactionsList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Emergency Fund
  static Future<void> saveEmergencyFund(double amount) async {
    if (isOnline) {
      try {
        await FirebaseService.saveEmergencyFund(amount);
        // Also save locally as backup
        await _prefs?.setDouble('emergency_fund', amount);
      } catch (e) {
        // If online fails, save locally
        await _prefs?.setDouble('emergency_fund', amount);
        throw Exception('Failed to sync online, saved locally: $e');
      }
    } else {
      await _prefs?.setDouble('emergency_fund', amount);
    }
  }

  static Future<double> getEmergencyFund() async {
    if (isOnline) {
      try {
        final amount = await FirebaseService.getEmergencyFund();
        // Update local backup
        await _prefs?.setDouble('emergency_fund', amount);
        return amount;
      } catch (e) {
        print('Online fetch failed, trying local: $e');
      }
    }

    // Fallback to local data
    return _prefs?.getDouble('emergency_fund') ?? 0.0;
  }

  // Investments
  static Future<void> saveInvestments(
    List<Map<String, dynamic>> investments,
  ) async {
    if (isOnline) {
      try {
        await FirebaseService.saveInvestments(investments);
        // Also save locally as backup
        await _prefs?.setString('investments', jsonEncode(investments));
      } catch (e) {
        // If online fails, save locally
        await _prefs?.setString('investments', jsonEncode(investments));
        throw Exception('Failed to sync online, saved locally: $e');
      }
    } else {
      await _prefs?.setString('investments', jsonEncode(investments));
    }
  }

  static Future<List<Map<String, dynamic>>> getInvestments() async {
    if (isOnline) {
      try {
        final investments = await FirebaseService.getInvestments();
        // Update local backup
        await _prefs?.setString('investments', jsonEncode(investments));
        return investments;
      } catch (e) {
        print('Online fetch failed, trying local: $e');
      }
    }

    // Fallback to local data
    final investmentsString = _prefs?.getString('investments');
    if (investmentsString != null) {
      final List<dynamic> investmentsList = jsonDecode(investmentsString);
      return investmentsList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // App Settings
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    if (isOnline) {
      try {
        await FirebaseService.saveAppSettings(settings);
        // Also save locally as backup
        await _prefs?.setString('app_settings', jsonEncode(settings));
      } catch (e) {
        // If online fails, save locally
        await _prefs?.setString('app_settings', jsonEncode(settings));
        throw Exception('Failed to sync online, saved locally: $e');
      }
    } else {
      await _prefs?.setString('app_settings', jsonEncode(settings));
    }
  }

  static Future<Map<String, dynamic>> getAppSettings() async {
    if (isOnline) {
      try {
        final settings = await FirebaseService.getAppSettings();
        // Update local backup
        await _prefs?.setString('app_settings', jsonEncode(settings));
        return settings;
      } catch (e) {
        print('Online fetch failed, trying local: $e');
      }
    }

    // Fallback to local data
    final settingsString = _prefs?.getString('app_settings');
    if (settingsString != null) {
      return jsonDecode(settingsString);
    }
    return {
      'theme': 'light',
      'language': 'English',
      'currency': 'Thai Baht (฿)',
      'monthly_start_date': 1,
      'daily_reminder': false,
      'spending_alerts': true,
      'goal_reminders': false,
      'budget_alerts': false,
    };
  }

  // Onboarding Status
  static Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs?.setBool('onboarding_completed', completed);
  }

  static bool isOnboardingCompleted() {
    return _prefs?.getBool('onboarding_completed') ?? false;
  }

  static Future<void> resetOnboardingStatus() async {
    await _prefs?.setBool('onboarding_completed', false);
  }

  // Budget Plans
  static Future<void> saveBudgetPlans(
    List<Map<String, dynamic>> budgets,
  ) async {
    await _prefs?.setString('budget_plans', jsonEncode(budgets));
  }

  static List<Map<String, dynamic>> getBudgetPlans() {
    final budgetsString = _prefs?.getString('budget_plans');
    if (budgetsString != null) {
      final List<dynamic> budgetsList = jsonDecode(budgetsString);
      return budgetsList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Financial Goals
  static Future<void> saveFinancialGoals(
    List<Map<String, dynamic>> goals,
  ) async {
    await _prefs?.setString('financial_goals', jsonEncode(goals));
  }

  static List<Map<String, dynamic>> getFinancialGoals() {
    final goalsString = _prefs?.getString('financial_goals');
    if (goalsString != null) {
      final List<dynamic> goalsList = jsonDecode(goalsString);
      return goalsList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Bookmarks
  static Future<void> saveBookmarks(
    Map<String, List<Map<String, dynamic>>> bookmarks,
  ) async {
    await _prefs?.setString('bookmarks', jsonEncode(bookmarks));
  }

  static Map<String, List<Map<String, dynamic>>> getBookmarks() {
    final bookmarksString = _prefs?.getString('bookmarks');
    if (bookmarksString != null) {
      final Map<String, dynamic> bookmarksMap = jsonDecode(bookmarksString);
      return bookmarksMap.map(
        (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
      );
    }
    return {'budgets': [], 'emergencies': []};
  }

  // Categories
  static Future<void> saveExpenseCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    await _prefs?.setString('expense_categories', jsonEncode(categories));
  }

  static List<Map<String, dynamic>> getExpenseCategories() {
    final categoriesString = _prefs?.getString('expense_categories');
    if (categoriesString != null) {
      final List<dynamic> categoriesList = jsonDecode(categoriesString);
      return categoriesList.cast<Map<String, dynamic>>();
    }
    return _getDefaultExpenseCategories();
  }

  static Future<void> saveIncomeCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    await _prefs?.setString('income_categories', jsonEncode(categories));
  }

  static List<Map<String, dynamic>> getIncomeCategories() {
    final categoriesString = _prefs?.getString('income_categories');
    if (categoriesString != null) {
      final List<dynamic> categoriesList = jsonDecode(categoriesString);
      return categoriesList.cast<Map<String, dynamic>>();
    }
    return _getDefaultIncomeCategories();
  }

  // Default Categories
  static List<Map<String, dynamic>> _getDefaultExpenseCategories() {
    return [
      {'name': 'Food', 'icon': 'Icons.restaurant', 'color': 'Colors.orange'},
      {'name': 'Daily', 'icon': 'Icons.shopping_cart', 'color': 'Colors.blue'},
      {
        'name': 'Transport',
        'icon': 'Icons.directions_car',
        'color': 'Colors.green',
      },
      {'name': 'Social', 'icon': 'Icons.people', 'color': 'Colors.purple'},
      {'name': 'Education', 'icon': 'Icons.school', 'color': 'Colors.indigo'},
      {
        'name': 'Health',
        'icon': 'Icons.medical_services',
        'color': 'Colors.red',
      },
      {'name': 'Entertainment', 'icon': 'Icons.movie', 'color': 'Colors.pink'},
      {'name': 'Utilities', 'icon': 'Icons.home', 'color': 'Colors.brown'},
      {'name': 'Others', 'icon': 'Icons.more_horiz', 'color': 'Colors.grey'},
    ];
  }

  static List<Map<String, dynamic>> _getDefaultIncomeCategories() {
    return [
      {'name': 'Salary', 'icon': 'Icons.work', 'color': 'Colors.green'},
      {'name': 'Freelance', 'icon': 'Icons.computer', 'color': 'Colors.blue'},
      {
        'name': 'Investment',
        'icon': 'Icons.trending_up',
        'color': 'Colors.purple',
      },
      {'name': 'Gift', 'icon': 'Icons.card_giftcard', 'color': 'Colors.pink'},
      {
        'name': 'Allowance',
        'icon': 'Icons.account_balance_wallet',
        'color': 'Colors.orange',
      },
      {'name': 'Others', 'icon': 'Icons.more_horiz', 'color': 'Colors.grey'},
    ];
  }

  // Sync local data to Firebase (for when user goes online)
  static Future<void> syncLocalDataToFirebase() async {
    if (!FirebaseService.isLoggedIn) return;

    try {
      // Sync user profile
      final profile = _prefs?.getString('user_profile');
      if (profile != null) {
        await FirebaseService.saveUserProfile(jsonDecode(profile));
      }

      // Sync financial data
      final financialData = {
        'currentBalance': _prefs?.getDouble('current_balance') ?? 0.0,
        'totalIncome': _prefs?.getDouble('total_income') ?? 0.0,
        'totalExpenses': _prefs?.getDouble('total_expenses') ?? 0.0,
      };
      await FirebaseService.saveFinancialData(
        currentBalance: financialData['currentBalance']!,
        totalIncome: financialData['totalIncome']!,
        totalExpenses: financialData['totalExpenses']!,
      );

      // Sync transactions
      final transactions = _prefs?.getString('transactions');
      if (transactions != null) {
        final List<dynamic> transactionsList = jsonDecode(transactions);
        await FirebaseService.saveTransactions(
          transactionsList.cast<Map<String, dynamic>>(),
        );
      }

      // Sync emergency fund
      final emergencyFund = _prefs?.getDouble('emergency_fund') ?? 0.0;
      await FirebaseService.saveEmergencyFund(emergencyFund);

      // Sync investments
      final investments = _prefs?.getString('investments');
      if (investments != null) {
        final List<dynamic> investmentsList = jsonDecode(investments);
        await FirebaseService.saveInvestments(
          investmentsList.cast<Map<String, dynamic>>(),
        );
      }

      // Sync settings
      final settings = _prefs?.getString('app_settings');
      if (settings != null) {
        await FirebaseService.saveAppSettings(jsonDecode(settings));
      }

      print('Local data synced to Firebase successfully');
    } catch (e) {
      print('Failed to sync local data to Firebase: $e');
      throw Exception('Failed to sync data: $e');
    }
  }
}
