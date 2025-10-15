// lib/constants/app_constants.dart
class AppConstants {
  // Currency
  static const String currencySymbol = '฿';
  static const String currencyCode = 'THB';

  // Default Values
  static const String defaultAsset = 'Cash';
  static const String defaultLedger = 'Personal';
  static const String defaultRemark = 'No remarks';
  static const String defaultTime = '12:00';

  // Asset Types
  static const List<String> assetTypes = [
    'Cash',
    'Credit Card',
    'Bank Account',
    'Digital Wallet',
    'Investment Account',
  ];

  // Ledger Types
  static const List<String> ledgerTypes = [
    'Personal',
    'Business',
    'Investment',
    'Savings',
    'Emergency Fund',
  ];

  // Transaction Types
  static const String expenseType = 'expense';
  static const String incomeType = 'income';

  // Default Times
  static const String morningTime = '09:00';
  static const String noonTime = '12:00';
  static const String eveningTime = '18:00';

  // Validation Limits
  static const double maxAmount = 999999999.0;
  static const double maxEmergencyFund = 10000000.0;
  static const double maxAllowance = 1000000.0;
  static const int maxCategoryLength = 50;
  static const int maxNameLength = 100;
  static const int maxRemarkLength = 200;

  // Date Ranges
  static const int maxPastYears = 1;
  static const int maxFutureYears = 1;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Snackbar Durations
  static const Duration shortSnackbar = Duration(seconds: 2);
  static const Duration mediumSnackbar = Duration(seconds: 3);
  static const Duration longSnackbar = Duration(seconds: 4);

  // Score Ratings
  static const String excellentScore = 'Excellent';
  static const String goodScore = 'Good';
  static const String fairScore = 'Fair';
  static const String poorScore = 'Poor';

  // Default Categories
  static const List<String> defaultExpenseCategories = [
    '🍕 Food & Dining',
    '🚗 Transportation',
    '🛒 Shopping',
    '🏠 Housing',
    '💡 Utilities',
    '🏥 Healthcare',
    '🎬 Entertainment',
    '📚 Education',
    '✈️ Travel',
    '💳 Other',
  ];

  static const List<String> defaultIncomeCategories = [
    '💰 Salary',
    '💼 Freelance',
    '📈 Investment',
    '🎁 Gift',
    '💸 Refund',
    '🏆 Bonus',
    '📊 Dividend',
    '💳 Other',
  ];

  // Error Messages
  static const String networkErrorMessage =
      'Network error: Please check your internet connection or try again later.';
  static const String genericErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String validationErrorMessage =
      'Please check your input and try again.';

  // Success Messages
  static const String transactionAddedMessage =
      'Transaction added successfully!';
  static const String transactionUpdatedMessage =
      'Transaction updated successfully!';
  static const String transactionDeletedMessage =
      'Transaction deleted successfully!';
  static const String balanceUpdatedMessage = 'Balance updated successfully!';
  static const String settingsSavedMessage = 'Settings saved successfully!';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String settingsCollection = 'settings';

  // SharedPreferences Keys
  static const String userProfileKey = 'user_profile';
  static const String currentBalanceKey = 'current_balance';
  static const String totalIncomeKey = 'total_income';
  static const String totalExpensesKey = 'total_expenses';
  static const String transactionsKey = 'transactions';
  static const String emergencyFundKey = 'emergency_fund';
  static const String investmentsKey = 'investments';
  static const String appSettingsKey = 'app_settings';
  static const String onboardingCompletedKey = 'onboarding_completed';
}
