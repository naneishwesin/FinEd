// lib/services/database_service.dart
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'expense_tracker.db';
  static const int _databaseVersion = 4; // Increment version for new tables

  // Table names
  static const String _transactionsTable = 'transactions';
  static const String _categoriesTable = 'categories';
  static const String _settingsTable = 'settings';
  static const String _balancesTable = 'balances';
  static const String _assetsTable = 'assets';
  static const String _liabilitiesTable = 'liabilities';
  static const String _budgetsTable = 'budgets';
  static const String _usersTable = 'users';
  static const String _financialGoalsTable = 'financial_goals';
  static const String _recurringTransactionsTable = 'recurring_transactions';
  static const String _investmentsTable = 'investments';
  static const String _emergencyFundsTable = 'emergency_funds';

  // Transaction table columns
  static const String _transactionId = 'id';
  static const String _transactionCategory = 'category';
  static const String _transactionAmount = 'amount';
  static const String _transactionDate = 'date';
  static const String _transactionTime = 'time';
  static const String _transactionAsset = 'asset';
  static const String _transactionLedger = 'ledger';
  static const String _transactionRemark = 'remark';
  static const String _transactionType = 'type';
  static const String _transactionCreatedAt = 'created_at';
  static const String _transactionUpdatedAt = 'updated_at';

  // Categories table columns
  static const String _categoryId = 'id';
  static const String _categoryName = 'name';
  static const String _categoryIcon = 'icon';
  static const String _categoryColor = 'color';
  static const String _categoryType = 'type'; // 'expense' or 'income'
  static const String _categoryIsDefault = 'is_default';
  static const String _categoryCreatedAt = 'created_at';

  // Settings table columns
  static const String _settingId = 'id';
  static const String _settingKey = 'key';
  static const String _settingValue = 'value';
  static const String _settingUpdatedAt = 'updated_at';

  // Balances table columns
  static const String _balanceId = 'id';
  static const String _balanceType =
      'type'; // 'current', 'emergency', 'investment'
  static const String _balanceAmount = 'amount';
  static const String _balanceUpdatedAt = 'updated_at';

  // Assets table columns
  static const String _assetId = 'id';
  static const String _assetName = 'name';
  static const String _assetAmount = 'amount';
  static const String _assetCategory = 'category';
  static const String _assetColor = 'color';
  static const String _assetCreatedAt = 'created_at';
  static const String _assetUpdatedAt = 'updated_at';

  // Liabilities table columns
  static const String _liabilityId = 'id';
  static const String _liabilityName = 'name';
  static const String _liabilityAmount = 'amount';
  static const String _liabilityCategory = 'category';
  static const String _liabilityColor = 'color';
  static const String _liabilityCreatedAt = 'created_at';
  static const String _liabilityUpdatedAt = 'updated_at';

  // Budgets table columns
  static const String _budgetId = 'id';
  static const String _budgetType = 'type'; // 'weekly', 'monthly', 'yearly'
  static const String _budgetAmount = 'amount';
  static const String _budgetSpent = 'spent';
  static const String _budgetCategory =
      'category'; // Optional: specific category budget
  static const String _budgetCreatedAt = 'created_at';
  static const String _budgetUpdatedAt = 'updated_at';

  // Users table columns
  static const String _userId = 'id';
  static const String _userEmail = 'email';
  static const String _userName = 'name';
  static const String _userProfileImage = 'profile_image';
  static const String _userCreatedAt = 'created_at';
  static const String _userUpdatedAt = 'updated_at';

  // Financial Goals table columns
  static const String _goalId = 'id';
  static const String _goalTitle = 'title';
  static const String _goalTargetAmount = 'target_amount';
  static const String _goalCurrentAmount = 'current_amount';
  static const String _goalTargetDate = 'target_date';
  static const String _goalCategory = 'category';
  static const String _goalPriority = 'priority';
  static const String _goalStatus = 'status';
  static const String _goalCreatedAt = 'created_at';
  static const String _goalUpdatedAt = 'updated_at';

  // Recurring Transactions table columns
  static const String _recurringId = 'id';
  static const String _recurringTitle = 'title';
  static const String _recurringAmount = 'amount';
  static const String _recurringCategory = 'category';
  static const String _recurringFrequency = 'frequency';
  static const String _recurringNextDueDate = 'next_due_date';
  static const String _recurringIsActive = 'is_active';
  static const String _recurringCreatedAt = 'created_at';
  static const String _recurringUpdatedAt = 'updated_at';

  // Investments table columns
  static const String _investmentId = 'id';
  static const String _investmentName = 'name';
  static const String _investmentType = 'type';
  static const String _investmentSymbol = 'symbol';
  static const String _investmentQuantity = 'quantity';
  static const String _investmentPurchasePrice = 'purchase_price';
  static const String _investmentCurrentPrice = 'current_price';
  static const String _investmentPurchaseDate = 'purchase_date';
  static const String _investmentCreatedAt = 'created_at';
  static const String _investmentUpdatedAt = 'updated_at';

  // Emergency Funds table columns
  static const String _emergencyId = 'id';
  static const String _emergencyName = 'name';
  static const String _emergencyTargetAmount = 'target_amount';
  static const String _emergencyCurrentAmount = 'current_amount';
  static const String _emergencyPriority = 'priority';
  static const String _emergencyCreatedAt = 'created_at';
  static const String _emergencyUpdatedAt = 'updated_at';

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE $_transactionsTable (
        $_transactionId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_transactionCategory TEXT NOT NULL,
        $_transactionAmount REAL NOT NULL,
        $_transactionDate TEXT NOT NULL,
        $_transactionTime TEXT NOT NULL,
        $_transactionAsset TEXT NOT NULL,
        $_transactionLedger TEXT NOT NULL,
        $_transactionRemark TEXT,
        $_transactionType TEXT NOT NULL,
        $_transactionCreatedAt TEXT NOT NULL,
        $_transactionUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE $_categoriesTable (
        $_categoryId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_categoryName TEXT NOT NULL UNIQUE,
        $_categoryIcon TEXT,
        $_categoryColor TEXT,
        $_categoryType TEXT NOT NULL,
        $_categoryIsDefault INTEGER NOT NULL DEFAULT 0,
        $_categoryCreatedAt TEXT NOT NULL
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE $_settingsTable (
        $_settingId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_settingKey TEXT NOT NULL UNIQUE,
        $_settingValue TEXT NOT NULL,
        $_settingUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create balances table
    await db.execute('''
      CREATE TABLE $_balancesTable (
        $_balanceId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_balanceType TEXT NOT NULL UNIQUE,
        $_balanceAmount REAL NOT NULL DEFAULT 0.0,
        $_balanceUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create assets table
    await db.execute('''
      CREATE TABLE $_assetsTable (
        $_assetId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_assetName TEXT NOT NULL,
        $_assetAmount REAL NOT NULL,
        $_assetCategory TEXT NOT NULL,
        $_assetColor TEXT NOT NULL,
        $_assetCreatedAt TEXT NOT NULL,
        $_assetUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create liabilities table
    await db.execute('''
      CREATE TABLE $_liabilitiesTable (
        $_liabilityId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_liabilityName TEXT NOT NULL,
        $_liabilityAmount REAL NOT NULL,
        $_liabilityCategory TEXT NOT NULL,
        $_liabilityColor TEXT NOT NULL,
        $_liabilityCreatedAt TEXT NOT NULL,
        $_liabilityUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE $_budgetsTable (
        $_budgetId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_budgetType TEXT NOT NULL,
        $_budgetAmount REAL NOT NULL,
        $_budgetSpent REAL DEFAULT 0,
        $_budgetCategory TEXT,
        $_budgetCreatedAt TEXT NOT NULL,
        $_budgetUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE $_usersTable (
        $_userId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_userEmail TEXT UNIQUE NOT NULL,
        $_userName TEXT NOT NULL,
        $_userProfileImage TEXT,
        $_userCreatedAt TEXT NOT NULL,
        $_userUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create financial goals table
    await db.execute('''
      CREATE TABLE $_financialGoalsTable (
        $_goalId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_goalTitle TEXT NOT NULL,
        $_goalTargetAmount REAL NOT NULL,
        $_goalCurrentAmount REAL DEFAULT 0,
        $_goalTargetDate TEXT,
        $_goalCategory TEXT,
        $_goalPriority INTEGER DEFAULT 1,
        $_goalStatus TEXT DEFAULT 'active',
        $_goalCreatedAt TEXT NOT NULL,
        $_goalUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create recurring transactions table
    await db.execute('''
      CREATE TABLE $_recurringTransactionsTable (
        $_recurringId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_recurringTitle TEXT NOT NULL,
        $_recurringAmount REAL NOT NULL,
        $_recurringCategory TEXT NOT NULL,
        $_recurringFrequency TEXT NOT NULL,
        $_recurringNextDueDate TEXT NOT NULL,
        $_recurringIsActive INTEGER DEFAULT 1,
        $_recurringCreatedAt TEXT NOT NULL,
        $_recurringUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create investments table
    await db.execute('''
      CREATE TABLE $_investmentsTable (
        $_investmentId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_investmentName TEXT NOT NULL,
        $_investmentType TEXT NOT NULL,
        $_investmentSymbol TEXT,
        $_investmentQuantity REAL NOT NULL,
        $_investmentPurchasePrice REAL NOT NULL,
        $_investmentCurrentPrice REAL,
        $_investmentPurchaseDate TEXT NOT NULL,
        $_investmentCreatedAt TEXT NOT NULL,
        $_investmentUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create emergency funds table
    await db.execute('''
      CREATE TABLE $_emergencyFundsTable (
        $_emergencyId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_emergencyName TEXT NOT NULL,
        $_emergencyTargetAmount REAL NOT NULL,
        $_emergencyCurrentAmount REAL DEFAULT 0,
        $_emergencyPriority INTEGER DEFAULT 1,
        $_emergencyCreatedAt TEXT NOT NULL,
        $_emergencyUpdatedAt TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);

    // Insert default balances
    await _insertDefaultBalances(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Create assets table
      await db.execute('''
        CREATE TABLE $_assetsTable (
          $_assetId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_assetName TEXT NOT NULL,
          $_assetAmount REAL NOT NULL,
          $_assetCategory TEXT NOT NULL,
          $_assetColor TEXT NOT NULL,
          $_assetCreatedAt TEXT NOT NULL,
          $_assetUpdatedAt TEXT NOT NULL
        )
      ''');

      // Create liabilities table
      await db.execute('''
        CREATE TABLE $_liabilitiesTable (
          $_liabilityId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_liabilityName TEXT NOT NULL,
          $_liabilityAmount REAL NOT NULL,
          $_liabilityCategory TEXT NOT NULL,
          $_liabilityColor TEXT NOT NULL,
          $_liabilityCreatedAt TEXT NOT NULL,
          $_liabilityUpdatedAt TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      // Create budgets table
      await db.execute('''
        CREATE TABLE $_budgetsTable (
          $_budgetId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_budgetType TEXT NOT NULL,
          $_budgetAmount REAL NOT NULL,
          $_budgetSpent REAL DEFAULT 0,
          $_budgetCategory TEXT,
          $_budgetCreatedAt TEXT NOT NULL,
          $_budgetUpdatedAt TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      // Create users table
      await db.execute('''
        CREATE TABLE $_usersTable (
          $_userId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_userEmail TEXT UNIQUE NOT NULL,
          $_userName TEXT NOT NULL,
          $_userProfileImage TEXT,
          $_userCreatedAt TEXT NOT NULL,
          $_userUpdatedAt TEXT NOT NULL
        )
      ''');

      // Create financial goals table
      await db.execute('''
        CREATE TABLE $_financialGoalsTable (
          $_goalId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_goalTitle TEXT NOT NULL,
          $_goalTargetAmount REAL NOT NULL,
          $_goalCurrentAmount REAL DEFAULT 0,
          $_goalTargetDate TEXT,
          $_goalCategory TEXT,
          $_goalPriority INTEGER DEFAULT 1,
          $_goalStatus TEXT DEFAULT 'active',
          $_goalCreatedAt TEXT NOT NULL,
          $_goalUpdatedAt TEXT NOT NULL
        )
      ''');

      // Create recurring transactions table
      await db.execute('''
        CREATE TABLE $_recurringTransactionsTable (
          $_recurringId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_recurringTitle TEXT NOT NULL,
          $_recurringAmount REAL NOT NULL,
          $_recurringCategory TEXT NOT NULL,
          $_recurringFrequency TEXT NOT NULL,
          $_recurringNextDueDate TEXT NOT NULL,
          $_recurringIsActive INTEGER DEFAULT 1,
          $_recurringCreatedAt TEXT NOT NULL,
          $_recurringUpdatedAt TEXT NOT NULL
        )
      ''');

      // Create investments table
      await db.execute('''
        CREATE TABLE $_investmentsTable (
          $_investmentId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_investmentName TEXT NOT NULL,
          $_investmentType TEXT NOT NULL,
          $_investmentSymbol TEXT,
          $_investmentQuantity REAL NOT NULL,
          $_investmentPurchasePrice REAL NOT NULL,
          $_investmentCurrentPrice REAL,
          $_investmentPurchaseDate TEXT NOT NULL,
          $_investmentCreatedAt TEXT NOT NULL,
          $_investmentUpdatedAt TEXT NOT NULL
        )
      ''');

      // Create emergency funds table
      await db.execute('''
        CREATE TABLE $_emergencyFundsTable (
          $_emergencyId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_emergencyName TEXT NOT NULL,
          $_emergencyTargetAmount REAL NOT NULL,
          $_emergencyCurrentAmount REAL DEFAULT 0,
          $_emergencyPriority INTEGER DEFAULT 1,
          $_emergencyCreatedAt TEXT NOT NULL,
          $_emergencyUpdatedAt TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        _categoryName: '🍕 Food & Dining',
        _categoryIcon: '🍕',
        _categoryColor: '#FF6B6B',
        _categoryType: 'expense',
        _categoryIsDefault: 1,
        _categoryCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        _categoryName: '🚗 Transportation',
        _categoryIcon: '🚗',
        _categoryColor: '#4ECDC4',
        _categoryType: 'expense',
        _categoryIsDefault: 1,
        _categoryCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        _categoryName: '🛍️ Shopping',
        _categoryIcon: '🛍️',
        _categoryColor: '#45B7D1',
        _categoryType: 'expense',
        _categoryIsDefault: 1,
        _categoryCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        _categoryName: '🏠 Housing',
        _categoryIcon: '🏠',
        _categoryColor: '#96CEB4',
        _categoryType: 'expense',
        _categoryIsDefault: 1,
        _categoryCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        _categoryName: '💼 Salary',
        _categoryIcon: '💼',
        _categoryColor: '#FFEAA7',
        _categoryType: 'income',
        _categoryIsDefault: 1,
        _categoryCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        _categoryName: '🎁 Allowance',
        _categoryIcon: '🎁',
        _categoryColor: '#DDA0DD',
        _categoryType: 'income',
        _categoryIsDefault: 1,
        _categoryCreatedAt: DateTime.now().toIso8601String(),
      },
    ];

    for (final category in defaultCategories) {
      await db.insert(_categoriesTable, category);
    }
  }

  Future<void> _insertDefaultBalances(Database db) async {
    final defaultBalances = [
      {
        _balanceType: 'current',
        _balanceAmount: 0.0,
        _balanceUpdatedAt: DateTime.now().toIso8601String(),
      },
      {
        _balanceType: 'emergency',
        _balanceAmount: 0.0,
        _balanceUpdatedAt: DateTime.now().toIso8601String(),
      },
      {
        _balanceType: 'investment',
        _balanceAmount: 0.0,
        _balanceUpdatedAt: DateTime.now().toIso8601String(),
      },
    ];

    for (final balance in defaultBalances) {
      await db.insert(_balancesTable, balance);
    }
  }

  // Transaction CRUD operations
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final transactionData = {
      _transactionCategory: transaction['category'],
      _transactionAmount: transaction['amount'],
      _transactionDate: transaction['date'],
      _transactionTime: transaction['time'],
      _transactionAsset: transaction['asset'],
      _transactionLedger: transaction['ledger'],
      _transactionRemark: transaction['remark'],
      _transactionType: transaction['type'],
      _transactionCreatedAt: now,
      _transactionUpdatedAt: now,
    };

    final id = await db.insert(_transactionsTable, transactionData);

    // Automatically recalculate all balances after transaction
    await recalculateAllBalances();

    return id;
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;

    // Use raw query for better performance with limit
    final result = await db.rawQuery('''
      SELECT * FROM $_transactionsTable 
      ORDER BY $_transactionDate DESC, $_transactionTime DESC
      LIMIT 1000
    ''');

    return result.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    return await db.query(
      _transactionsTable,
      where: '$_transactionDate BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: '$_transactionDate DESC, $_transactionTime DESC',
    );
  }

  /// Get spending by category (for reports)
  Future<Map<String, double>> getSpendingByCategory() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT $_transactionCategory, SUM(ABS($_transactionAmount)) as total
      FROM $_transactionsTable
      WHERE $_transactionType = 'expense'
      GROUP BY $_transactionCategory
      ORDER BY total DESC
    ''');

    final Map<String, double> spendingByCategory = {};
    for (final row in result) {
      spendingByCategory[row[_transactionCategory] as String] =
          (row['total'] as double?) ?? 0.0;
    }

    return spendingByCategory;
  }

  Future<List<Map<String, dynamic>>> getTransactionsByType(String type) async {
    final db = await database;
    return await db.query(
      _transactionsTable,
      where: '$_transactionType = ?',
      whereArgs: [type],
      orderBy: '$_transactionDate DESC, $_transactionTime DESC',
    );
  }

  Future<Map<String, dynamic>?> getTransactionById(int id) async {
    final db = await database;
    final results = await db.query(
      _transactionsTable,
      where: '$_transactionId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateTransaction(
    int id,
    Map<String, dynamic> transaction,
  ) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final transactionData = {
      _transactionCategory: transaction['category'],
      _transactionAmount: transaction['amount'],
      _transactionDate: transaction['date'],
      _transactionTime: transaction['time'],
      _transactionAsset: transaction['asset'],
      _transactionLedger: transaction['ledger'],
      _transactionRemark: transaction['remark'],
      _transactionType: transaction['type'],
      _transactionUpdatedAt: now,
    };

    final result = await db.update(
      _transactionsTable,
      transactionData,
      where: '$_transactionId = ?',
      whereArgs: [id],
    );

    // Automatically recalculate all balances after transaction update
    await recalculateAllBalances();

    return result;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    final result = await db.delete(
      _transactionsTable,
      where: '$_transactionId = ?',
      whereArgs: [id],
    );

    // Automatically recalculate all balances after transaction deletion
    await recalculateAllBalances();

    return result;
  }

  // Balance operations
  Future<double> getCurrentBalance() async {
    final db = await database;
    final results = await db.query(
      _balancesTable,
      where: '$_balanceType = ?',
      whereArgs: ['current'],
    );
    return results.isNotEmpty ? results.first[_balanceAmount] as double : 0.0;
  }

  Future<double> getEmergencyBalance() async {
    final db = await database;
    final results = await db.query(
      _balancesTable,
      where: '$_balanceType = ?',
      whereArgs: ['emergency'],
    );
    return results.isNotEmpty ? results.first[_balanceAmount] as double : 0.0;
  }

  Future<double> getInvestmentBalance() async {
    final db = await database;
    final results = await db.query(
      _balancesTable,
      where: '$_balanceType = ?',
      whereArgs: ['investment'],
    );
    return results.isNotEmpty ? results.first[_balanceAmount] as double : 0.0;
  }

  Future<void> updateBalance(String type, double amount) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      _balancesTable,
      {_balanceAmount: amount, _balanceUpdatedAt: now},
      where: '$_balanceType = ?',
      whereArgs: [type],
    );
  }

  Future<void> _updateBalanceFromTransactions() async {
    final db = await database;

    // Calculate current balance from all transactions
    // Income adds to balance (positive), expenses subtract from balance (negative)
    final result = await db.rawQuery('''
      SELECT SUM($_transactionAmount) as total
      FROM $_transactionsTable
    ''');

    final total = result.first['total'] as double? ?? 0.0;
    await updateBalance('current', total);
  }

  /// Comprehensive balance recalculation system
  Future<void> recalculateAllBalances() async {
    final db = await database;

    try {
      // 1. Recalculate current balance from transactions
      await _updateBalanceFromTransactions();

      // 2. Recalculate emergency fund balance
      final emergencyResult = await db.rawQuery('''
        SELECT SUM($_emergencyCurrentAmount) as total
        FROM $_emergencyFundsTable
      ''');
      final emergencyTotal = emergencyResult.first['total'] as double? ?? 0.0;
      await updateBalance('emergency', emergencyTotal);

      // 3. Recalculate investment balance
      final investmentResult = await db.rawQuery('''
        SELECT SUM($_investmentQuantity * COALESCE($_investmentCurrentPrice, $_investmentPurchasePrice)) as total
        FROM $_investmentsTable
      ''');
      final investmentTotal = investmentResult.first['total'] as double? ?? 0.0;
      await updateBalance('investment', investmentTotal);

      // 4. Update budget spent amounts
      await _updateBudgetSpentAmounts();

      print('All balances recalculated successfully');
    } catch (e) {
      print('Error recalculating balances: $e');
      rethrow;
    }
  }

  /// Update budget spent amounts based on actual transactions
  Future<void> _updateBudgetSpentAmounts() async {
    final db = await database;

    // Update weekly budget spent
    final weeklyStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final weeklyEnd = weeklyStart.add(Duration(days: 6));

    final weeklySpent = await db.rawQuery(
      '''
      SELECT SUM(ABS($_transactionAmount)) as total
      FROM $_transactionsTable
      WHERE $_transactionType = 'expense'
      AND $_transactionDate >= ? AND $_transactionDate <= ?
    ''',
      [
        weeklyStart.toIso8601String().split('T')[0],
        weeklyEnd.toIso8601String().split('T')[0],
      ],
    );

    await db.update(
      _budgetsTable,
      {_budgetSpent: weeklySpent.first['total'] as double? ?? 0.0},
      where: '$_budgetType = ?',
      whereArgs: ['weekly'],
    );

    // Update monthly budget spent
    final monthlyStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final monthlyEnd = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      0,
    );

    final monthlySpent = await db.rawQuery(
      '''
      SELECT SUM(ABS($_transactionAmount)) as total
      FROM $_transactionsTable
      WHERE $_transactionType = 'expense'
      AND $_transactionDate >= ? AND $_transactionDate <= ?
    ''',
      [
        monthlyStart.toIso8601String().split('T')[0],
        monthlyEnd.toIso8601String().split('T')[0],
      ],
    );

    await db.update(
      _budgetsTable,
      {_budgetSpent: monthlySpent.first['total'] as double? ?? 0.0},
      where: '$_budgetType = ?',
      whereArgs: ['monthly'],
    );

    // Update yearly budget spent
    final yearlyStart = DateTime(DateTime.now().year, 1, 1);
    final yearlyEnd = DateTime(DateTime.now().year, 12, 31);

    final yearlySpent = await db.rawQuery(
      '''
      SELECT SUM(ABS($_transactionAmount)) as total
      FROM $_transactionsTable
      WHERE $_transactionType = 'expense'
      AND $_transactionDate >= ? AND $_transactionDate <= ?
    ''',
      [
        yearlyStart.toIso8601String().split('T')[0],
        yearlyEnd.toIso8601String().split('T')[0],
      ],
    );

    await db.update(
      _budgetsTable,
      {_budgetSpent: yearlySpent.first['total'] as double? ?? 0.0},
      where: '$_budgetType = ?',
      whereArgs: ['yearly'],
    );
  }

  // Category operations
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query(
      _categoriesTable,
      orderBy: '$_categoryType, $_categoryName',
    );
  }

  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    final db = await database;
    return await db.query(
      _categoriesTable,
      where: '$_categoryType = ?',
      whereArgs: [type],
      orderBy: _categoryName,
    );
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final categoryData = {
      _categoryName: category['name'],
      _categoryIcon: category['icon'],
      _categoryColor: category['color'],
      _categoryType: category['type'],
      _categoryIsDefault: category['is_default'] ?? 0,
      _categoryCreatedAt: now,
    };

    return await db.insert(_categoriesTable, categoryData);
  }

  // Settings operations
  Future<void> setSetting(String key, dynamic value) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.insert(_settingsTable, {
      _settingKey: key,
      _settingValue: jsonEncode(value),
      _settingUpdatedAt: now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<T?> getSetting<T>(String key) async {
    final db = await database;
    final results = await db.query(
      _settingsTable,
      where: '$_settingKey = ?',
      whereArgs: [key],
    );

    if (results.isNotEmpty) {
      final value = results.first[_settingValue] as String;
      return jsonDecode(value) as T?;
    }
    return null;
  }

  /// Get transactions by asset type
  Future<List<Map<String, dynamic>>> getTransactionsByAsset(
    String asset,
  ) async {
    final db = await database;
    return await db.query(
      _transactionsTable,
      where: '$_transactionAsset = ?',
      whereArgs: [asset],
      orderBy: '$_transactionDate DESC, $_transactionTime DESC',
    );
  }

  // Statistics and analytics

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM($_transactionAmount) as total
      FROM $_transactionsTable
      WHERE $_transactionType = 'expense'
    ''');

    return (result.first['total'] as double?)?.abs() ?? 0.0;
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM($_transactionAmount) as total
      FROM $_transactionsTable
      WHERE $_transactionType = 'income'
    ''');

    return result.first['total'] as double? ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTransactions(
    int year,
    int month,
  ) async {
    final db = await database;
    final startDate = DateTime(year, month, 1).toIso8601String().split('T')[0];
    final endDate = DateTime(
      year,
      month + 1,
      0,
    ).toIso8601String().split('T')[0];

    return await db.query(
      _transactionsTable,
      where: '$_transactionDate BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '$_transactionDate DESC, $_transactionTime DESC',
    );
  }

  // Assets operations
  Future<List<Map<String, dynamic>>> getAllAssets() async {
    final db = await database;
    return await db.query(_assetsTable, orderBy: '$_assetCreatedAt DESC');
  }

  Future<int> insertAsset(Map<String, dynamic> asset) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final assetData = {
      _assetName: asset['name'],
      _assetAmount: asset['amount'],
      _assetCategory: asset['category'],
      _assetColor: asset['color'],
      _assetCreatedAt: now,
      _assetUpdatedAt: now,
    };

    return await db.insert(_assetsTable, assetData);
  }

  Future<int> updateAsset(int id, Map<String, dynamic> asset) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final assetData = {
      _assetName: asset['name'],
      _assetAmount: asset['amount'],
      _assetCategory: asset['category'],
      _assetColor: asset['color'],
      _assetUpdatedAt: now,
    };

    return await db.update(
      _assetsTable,
      assetData,
      where: '$_assetId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAsset(int id) async {
    final db = await database;
    return await db.delete(
      _assetsTable,
      where: '$_assetId = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalAssets() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM($_assetAmount) as total
      FROM $_assetsTable
    ''');
    return result.first['total'] as double? ?? 0.0;
  }

  // Liabilities operations
  Future<List<Map<String, dynamic>>> getAllLiabilities() async {
    final db = await database;
    return await db.query(
      _liabilitiesTable,
      orderBy: '$_liabilityCreatedAt DESC',
    );
  }

  Future<int> insertLiability(Map<String, dynamic> liability) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final liabilityData = {
      _liabilityName: liability['name'],
      _liabilityAmount: liability['amount'],
      _liabilityCategory: liability['category'],
      _liabilityColor: liability['color'],
      _liabilityCreatedAt: now,
      _liabilityUpdatedAt: now,
    };

    return await db.insert(_liabilitiesTable, liabilityData);
  }

  Future<int> updateLiability(int id, Map<String, dynamic> liability) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final liabilityData = {
      _liabilityName: liability['name'],
      _liabilityAmount: liability['amount'],
      _liabilityCategory: liability['category'],
      _liabilityColor: liability['color'],
      _liabilityUpdatedAt: now,
    };

    return await db.update(
      _liabilitiesTable,
      liabilityData,
      where: '$_liabilityId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLiability(int id) async {
    final db = await database;
    return await db.delete(
      _liabilitiesTable,
      where: '$_liabilityId = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalLiabilities() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM($_liabilityAmount) as total
      FROM $_liabilitiesTable
    ''');
    return result.first['total'] as double? ?? 0.0;
  }

  // Budget operations
  Future<List<Map<String, dynamic>>> getAllBudgets() async {
    final db = await database;
    return await db.query(_budgetsTable, orderBy: '$_budgetType ASC');
  }

  Future<Map<String, dynamic>?> getBudgetByType(String type) async {
    final db = await database;
    final result = await db.query(
      _budgetsTable,
      where: '$_budgetType = ?',
      whereArgs: [type],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final budgetData = {
      _budgetType: budget['type'],
      _budgetAmount: budget['amount'],
      _budgetSpent: budget['spent'] ?? 0.0,
      _budgetCategory: budget['category'],
      _budgetCreatedAt: now,
      _budgetUpdatedAt: now,
    };

    return await db.insert(_budgetsTable, budgetData);
  }

  Future<int> updateBudget(int id, Map<String, dynamic> budget) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final budgetData = {
      _budgetType: budget['type'],
      _budgetAmount: budget['amount'],
      _budgetSpent: budget['spent'] ?? 0.0,
      _budgetCategory: budget['category'],
      _budgetUpdatedAt: now,
    };

    return await db.update(
      _budgetsTable,
      budgetData,
      where: '$_budgetId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateBudgetSpent(String type, double spent) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return await db.update(
      _budgetsTable,
      {_budgetSpent: spent, _budgetUpdatedAt: now},
      where: '$_budgetType = ?',
      whereArgs: [type],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete(
      _budgetsTable,
      where: '$_budgetId = ?',
      whereArgs: [id],
    );
  }

  Future<double> getBudgetSpent(String type) async {
    final db = await database;
    final result = await db.query(
      _budgetsTable,
      columns: [_budgetSpent],
      where: '$_budgetType = ?',
      whereArgs: [type],
    );
    return result.isNotEmpty
        ? (result.first[_budgetSpent] as double? ?? 0.0)
        : 0.0;
  }

  Future<double> getBudgetAmount(String type) async {
    final db = await database;
    final result = await db.query(
      _budgetsTable,
      columns: [_budgetAmount],
      where: '$_budgetType = ?',
      whereArgs: [type],
    );
    return result.isNotEmpty
        ? (result.first[_budgetAmount] as double? ?? 0.0)
        : 0.0;
  }

  // Budget alert system
  Future<Map<String, dynamic>> getBudgetStatus(String type) async {
    final budget = await getBudgetByType(type);
    if (budget == null) {
      return {
        'status': 'no_budget',
        'percentage': 0.0,
        'remaining': 0.0,
        'overAmount': 0.0,
      };
    }

    final amount = budget[_budgetAmount] as double;
    final spent = budget[_budgetSpent] as double;
    final percentage = amount > 0 ? (spent / amount) : 0.0;
    final remaining = amount - spent;
    final overAmount = spent > amount ? spent - amount : 0.0;

    String status;
    if (percentage >= 1.0) {
      status = 'over_budget';
    } else if (percentage >= 0.8) {
      status = 'warning';
    } else {
      status = 'good';
    }

    return {
      'status': status,
      'percentage': percentage,
      'remaining': remaining,
      'overAmount': overAmount,
      'amount': amount,
      'spent': spent,
    };
  }

  // Financial Goals operations
  Future<List<Map<String, dynamic>>> getAllFinancialGoals() async {
    final db = await database;
    return await db.query(
      _financialGoalsTable,
      orderBy: '$_goalPriority ASC, $_goalCreatedAt DESC',
    );
  }

  Future<Map<String, dynamic>?> getFinancialGoal(int id) async {
    final db = await database;
    final result = await db.query(
      _financialGoalsTable,
      where: '$_goalId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertFinancialGoal(Map<String, dynamic> goal) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final goalData = {
      _goalTitle: goal['title'],
      _goalTargetAmount: goal['target_amount'],
      _goalCurrentAmount: goal['current_amount'] ?? 0.0,
      _goalTargetDate: goal['target_date'],
      _goalCategory: goal['category'],
      _goalPriority: goal['priority'] ?? 1,
      _goalStatus: goal['status'] ?? 'active',
      _goalCreatedAt: now,
      _goalUpdatedAt: now,
    };

    return await db.insert(_financialGoalsTable, goalData);
  }

  Future<int> updateFinancialGoal(int id, Map<String, dynamic> goal) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final goalData = {
      _goalTitle: goal['title'],
      _goalTargetAmount: goal['target_amount'],
      _goalCurrentAmount: goal['current_amount'] ?? 0.0,
      _goalTargetDate: goal['target_date'],
      _goalCategory: goal['category'],
      _goalPriority: goal['priority'] ?? 1,
      _goalStatus: goal['status'] ?? 'active',
      _goalUpdatedAt: now,
    };

    return await db.update(
      _financialGoalsTable,
      goalData,
      where: '$_goalId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFinancialGoal(int id) async {
    final db = await database;
    return await db.delete(
      _financialGoalsTable,
      where: '$_goalId = ?',
      whereArgs: [id],
    );
  }

  // Recurring Transactions operations
  Future<List<Map<String, dynamic>>> getAllRecurringTransactions() async {
    final db = await database;
    return await db.query(
      _recurringTransactionsTable,
      orderBy: '$_recurringNextDueDate ASC',
    );
  }

  Future<Map<String, dynamic>?> getRecurringTransaction(int id) async {
    final db = await database;
    final result = await db.query(
      _recurringTransactionsTable,
      where: '$_recurringId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertRecurringTransaction(Map<String, dynamic> recurring) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final recurringData = {
      _recurringTitle: recurring['title'],
      _recurringAmount: recurring['amount'],
      _recurringCategory: recurring['category'],
      _recurringFrequency: recurring['frequency'],
      _recurringNextDueDate: recurring['next_due_date'],
      _recurringIsActive: recurring['is_active'] ?? 1,
      _recurringCreatedAt: now,
      _recurringUpdatedAt: now,
    };

    return await db.insert(_recurringTransactionsTable, recurringData);
  }

  Future<int> updateRecurringTransaction(
    int id,
    Map<String, dynamic> recurring,
  ) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final recurringData = {
      _recurringTitle: recurring['title'],
      _recurringAmount: recurring['amount'],
      _recurringCategory: recurring['category'],
      _recurringFrequency: recurring['frequency'],
      _recurringNextDueDate: recurring['next_due_date'],
      _recurringIsActive: recurring['is_active'] ?? 1,
      _recurringUpdatedAt: now,
    };

    return await db.update(
      _recurringTransactionsTable,
      recurringData,
      where: '$_recurringId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecurringTransaction(int id) async {
    final db = await database;
    return await db.delete(
      _recurringTransactionsTable,
      where: '$_recurringId = ?',
      whereArgs: [id],
    );
  }

  // Investments operations
  Future<List<Map<String, dynamic>>> getAllInvestments() async {
    final db = await database;
    return await db.query(
      _investmentsTable,
      orderBy: '$_investmentCreatedAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getInvestments() async {
    try {
      final investments = await getAllInvestments();
      return investments
          .map(
            (investment) => {
              'name': investment[_investmentName],
              'type': investment[_investmentType],
              'symbol': investment[_investmentSymbol],
              'quantity': investment[_investmentQuantity],
              'purchase_price': investment[_investmentPurchasePrice],
              'current_price':
                  investment[_investmentCurrentPrice] ??
                  investment[_investmentPurchasePrice],
              'purchase_date': investment[_investmentPurchaseDate],
              'amount':
                  (investment[_investmentQuantity] as double) *
                  (investment[_investmentCurrentPrice] as double? ??
                      investment[_investmentPurchasePrice] as double),
            },
          )
          .toList();
    } catch (e) {
      print('Error getting investments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getInvestment(int id) async {
    final db = await database;
    final result = await db.query(
      _investmentsTable,
      where: '$_investmentId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertInvestment(Map<String, dynamic> investment) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final investmentData = {
      _investmentName: investment['name'],
      _investmentType: investment['type'],
      _investmentSymbol: investment['symbol'],
      _investmentQuantity: investment['quantity'],
      _investmentPurchasePrice: investment['purchase_price'],
      _investmentCurrentPrice: investment['current_price'],
      _investmentPurchaseDate: investment['purchase_date'],
      _investmentCreatedAt: now,
      _investmentUpdatedAt: now,
    };

    return await db.insert(_investmentsTable, investmentData);
  }

  Future<int> updateInvestment(int id, Map<String, dynamic> investment) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final investmentData = {
      _investmentName: investment['name'],
      _investmentType: investment['type'],
      _investmentSymbol: investment['symbol'],
      _investmentQuantity: investment['quantity'],
      _investmentPurchasePrice: investment['purchase_price'],
      _investmentCurrentPrice: investment['current_price'],
      _investmentPurchaseDate: investment['purchase_date'],
      _investmentUpdatedAt: now,
    };

    return await db.update(
      _investmentsTable,
      investmentData,
      where: '$_investmentId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteInvestment(int id) async {
    final db = await database;
    return await db.delete(
      _investmentsTable,
      where: '$_investmentId = ?',
      whereArgs: [id],
    );
  }

  // Emergency Funds operations
  Future<List<Map<String, dynamic>>> getAllEmergencyFunds() async {
    final db = await database;
    return await db.query(
      _emergencyFundsTable,
      orderBy: '$_emergencyPriority ASC, $_emergencyCreatedAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getEmergencyFunds() async {
    return getAllEmergencyFunds();
  }

  Future<Map<String, dynamic>?> getEmergencyFund(int id) async {
    final db = await database;
    final result = await db.query(
      _emergencyFundsTable,
      where: '$_emergencyId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertEmergencyFund(Map<String, dynamic> emergencyFund) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final emergencyData = {
      _emergencyName: emergencyFund['name'],
      _emergencyTargetAmount: emergencyFund['target_amount'],
      _emergencyCurrentAmount: emergencyFund['current_amount'] ?? 0.0,
      _emergencyPriority: emergencyFund['priority'] ?? 1,
      _emergencyCreatedAt: now,
      _emergencyUpdatedAt: now,
    };

    return await db.insert(_emergencyFundsTable, emergencyData);
  }

  Future<int> updateEmergencyFund(
    int id,
    Map<String, dynamic> emergencyFund,
  ) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final emergencyData = {
      _emergencyName: emergencyFund['name'],
      _emergencyTargetAmount: emergencyFund['target_amount'],
      _emergencyCurrentAmount: emergencyFund['current_amount'] ?? 0.0,
      _emergencyPriority: emergencyFund['priority'] ?? 1,
      _emergencyUpdatedAt: now,
    };

    return await db.update(
      _emergencyFundsTable,
      emergencyData,
      where: '$_emergencyId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEmergencyFund(int id) async {
    final db = await database;
    return await db.delete(
      _emergencyFundsTable,
      where: '$_emergencyId = ?',
      whereArgs: [id],
    );
  }

  // Users operations
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query(_usersTable, orderBy: '$_userCreatedAt DESC');
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final result = await db.query(
      _usersTable,
      where: '$_userId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      _usersTable,
      where: '$_userEmail = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final userData = {
      _userEmail: user['email'],
      _userName: user['name'],
      _userProfileImage: user['profile_image'],
      _userCreatedAt: now,
      _userUpdatedAt: now,
    };

    return await db.insert(_usersTable, userData);
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final userData = {
      _userEmail: user['email'],
      _userName: user['name'],
      _userProfileImage: user['profile_image'],
      _userUpdatedAt: now,
    };

    return await db.update(
      _usersTable,
      userData,
      where: '$_userId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(_usersTable, where: '$_userId = ?', whereArgs: [id]);
  }

  // Database maintenance
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_transactionsTable);
    await db.delete(_balancesTable);
    await db.delete(_settingsTable);

    // Reset balances to default
    await _insertDefaultBalances(db);
  }

  /// Add sample data for the last month
  Future<void> addSampleData() async {
    final db = await database;
    final now = DateTime.now();

    // Check if we already have transactions
    final existingTransactions = await db.query(_transactionsTable);
    print('Existing transactions count: ${existingTransactions.length}');

    if (existingTransactions.length >= 35) {
      print(
        'Sample data already exists (${existingTransactions.length} transactions), skipping...',
      );
      return;
    }

    print(
      'Adding sample data... (current count: ${existingTransactions.length})',
    );

    // Sample transactions for the last 60 days (last month + this month)
    final sampleTransactions = [
      // THIS MONTH INCOME (Recent)
      {
        'category': '💼 Salary',
        'amount': 25000.0,
        'date': now
            .subtract(const Duration(days: 2))
            .toIso8601String()
            .split('T')[0],
        'time': '09:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Monthly salary - December',
        'type': 'income',
      },
      {
        'category': '💳 Freelance',
        'amount': 8000.0,
        'date': now
            .subtract(const Duration(days: 5))
            .toIso8601String()
            .split('T')[0],
        'time': '16:00',
        'asset': 'Cash',
        'ledger': 'Work',
        'remark': 'Web development project',
        'type': 'income',
      },
      {
        'category': '🎁 Bonus',
        'amount': 5000.0,
        'date': now
            .subtract(const Duration(days: 8))
            .toIso8601String()
            .split('T')[0],
        'time': '14:00',
        'asset': 'Cash',
        'ledger': 'Work',
        'remark': 'Year-end bonus',
        'type': 'income',
      },
      {
        'category': '📈 Investment Return',
        'amount': 1200.0,
        'date': now
            .subtract(const Duration(days: 12))
            .toIso8601String()
            .split('T')[0],
        'time': '10:00',
        'asset': 'Investment',
        'ledger': 'Investment',
        'remark': 'Stock dividend',
        'type': 'income',
      },

      // THIS MONTH EXPENSES (Recent)
      {
        'category': '🍕 Food & Dining',
        'amount': -450.0,
        'date': now
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0],
        'time': '12:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Lunch at restaurant',
        'type': 'expense',
      },
      {
        'category': '🚗 Transportation',
        'amount': -320.0,
        'date': now
            .subtract(const Duration(days: 2))
            .toIso8601String()
            .split('T')[0],
        'time': '08:30',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Bus fare and taxi',
        'type': 'expense',
      },
      {
        'category': '🛍️ Shopping',
        'amount': -1200.0,
        'date': now
            .subtract(const Duration(days: 3))
            .toIso8601String()
            .split('T')[0],
        'time': '15:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Clothes shopping',
        'type': 'expense',
      },
      {
        'category': '🏠 Housing',
        'amount': -8000.0,
        'date': now
            .subtract(const Duration(days: 5))
            .toIso8601String()
            .split('T')[0],
        'time': '09:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Rent payment',
        'type': 'expense',
      },
      {
        'category': '🍕 Food & Dining',
        'amount': -280.0,
        'date': now
            .subtract(const Duration(days: 6))
            .toIso8601String()
            .split('T')[0],
        'time': '19:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Dinner',
        'type': 'expense',
      },
      {
        'category': '🚗 Transportation',
        'amount': -150.0,
        'date': now
            .subtract(const Duration(days: 8))
            .toIso8601String()
            .split('T')[0],
        'time': '07:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Taxi',
        'type': 'expense',
      },
      {
        'category': '🛍️ Shopping',
        'amount': -800.0,
        'date': now
            .subtract(const Duration(days: 10))
            .toIso8601String()
            .split('T')[0],
        'time': '14:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Groceries',
        'type': 'expense',
      },
      {
        'category': '🍕 Food & Dining',
        'amount': -350.0,
        'date': now
            .subtract(const Duration(days: 12))
            .toIso8601String()
            .split('T')[0],
        'time': '12:30',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Restaurant',
        'type': 'expense',
      },
      {
        'category': '🚗 Transportation',
        'amount': -200.0,
        'date': now
            .subtract(const Duration(days: 15))
            .toIso8601String()
            .split('T')[0],
        'time': '18:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Fuel',
        'type': 'expense',
      },
      {
        'category': '🛍️ Shopping',
        'amount': -600.0,
        'date': now
            .subtract(const Duration(days: 18))
            .toIso8601String()
            .split('T')[0],
        'time': '16:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Electronics',
        'type': 'expense',
      },
      {
        'category': '🍕 Food & Dining',
        'amount': -180.0,
        'date': now
            .subtract(const Duration(days: 20))
            .toIso8601String()
            .split('T')[0],
        'time': '11:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Coffee',
        'type': 'expense',
      },
      {
        'category': '🚗 Transportation',
        'amount': -100.0,
        'date': now
            .subtract(const Duration(days: 22))
            .toIso8601String()
            .split('T')[0],
        'time': '09:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'BTS',
        'type': 'expense',
      },
      {
        'category': '🛍️ Shopping',
        'amount': -400.0,
        'date': now
            .subtract(const Duration(days: 25))
            .toIso8601String()
            .split('T')[0],
        'time': '13:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Books',
        'type': 'expense',
      },
      {
        'category': '🍕 Food & Dining',
        'amount': -220.0,
        'date': now
            .subtract(const Duration(days: 28))
            .toIso8601String()
            .split('T')[0],
        'time': '20:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Snacks',
        'type': 'expense',
      },

      // LAST MONTH INCOME (November)
      {
        'category': '💼 Salary',
        'amount': 25000.0,
        'date': now
            .subtract(const Duration(days: 32))
            .toIso8601String()
            .split('T')[0],
        'time': '09:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Monthly salary - November',
        'type': 'income',
      },
      {
        'category': '💳 Freelance',
        'amount': 6000.0,
        'date': now
            .subtract(const Duration(days: 35))
            .toIso8601String()
            .split('T')[0],
        'time': '16:00',
        'asset': 'Cash',
        'ledger': 'Work',
        'remark': 'Mobile app development',
        'type': 'income',
      },
      {
        'category': '🎁 Allowance',
        'amount': 3000.0,
        'date': now
            .subtract(const Duration(days: 38))
            .toIso8601String()
            .split('T')[0],
        'time': '10:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Monthly allowance',
        'type': 'income',
      },
      {
        'category': '📈 Investment Return',
        'amount': 800.0,
        'date': now
            .subtract(const Duration(days: 42))
            .toIso8601String()
            .split('T')[0],
        'time': '10:00',
        'asset': 'Investment',
        'ledger': 'Investment',
        'remark': 'Bond interest',
        'type': 'income',
      },

      // LAST MONTH EXPENSES (November)
      {
        'category': '🍕 Food & Dining',
        'amount': -380.0,
        'date': now
            .subtract(const Duration(days: 30))
            .toIso8601String()
            .split('T')[0],
        'time': '12:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Lunch',
        'type': 'expense',
      },
      {
        'category': '🚗 Transportation',
        'amount': -250.0,
        'date': now
            .subtract(const Duration(days: 33))
            .toIso8601String()
            .split('T')[0],
        'time': '08:30',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Bus fare',
        'type': 'expense',
      },
      {
        'category': '🛍️ Shopping',
        'amount': -1500.0,
        'date': now
            .subtract(const Duration(days: 36))
            .toIso8601String()
            .split('T')[0],
        'time': '15:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Black Friday shopping',
        'type': 'expense',
      },
      {
        'category': '🏠 Housing',
        'amount': -8000.0,
        'date': now
            .subtract(const Duration(days: 38))
            .toIso8601String()
            .split('T')[0],
        'time': '09:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Rent payment',
        'type': 'expense',
      },
      {
        'category': '🍕 Food & Dining',
        'amount': -320.0,
        'date': now
            .subtract(const Duration(days: 40))
            .toIso8601String()
            .split('T')[0],
        'time': '19:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Dinner',
        'type': 'expense',
      },
      {
        'category': '🚗 Transportation',
        'amount': -180.0,
        'date': now
            .subtract(const Duration(days: 42))
            .toIso8601String()
            .split('T')[0],
        'time': '07:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Taxi',
        'type': 'expense',
      },
      {
        'category': '🛍️ Shopping',
        'amount': -900.0,
        'date': now
            .subtract(const Duration(days: 45))
            .toIso8601String()
            .split('T')[0],
        'time': '14:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Groceries',
        'type': 'expense',
      },
      {
        'category': '🍕 Food & Dining',
        'amount': -290.0,
        'date': now
            .subtract(const Duration(days: 48))
            .toIso8601String()
            .split('T')[0],
        'time': '12:30',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Restaurant',
        'type': 'expense',
      },
      {
        'category': '🚗 Transportation',
        'amount': -220.0,
        'date': now
            .subtract(const Duration(days: 50))
            .toIso8601String()
            .split('T')[0],
        'time': '18:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Fuel',
        'type': 'expense',
      },
      {
        'category': '🛍️ Shopping',
        'amount': -700.0,
        'date': now
            .subtract(const Duration(days: 52))
            .toIso8601String()
            .split('T')[0],
        'time': '16:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Electronics',
        'type': 'expense',
      },
      {
        'category': '🍕 Food & Dining',
        'amount': -160.0,
        'date': now
            .subtract(const Duration(days: 55))
            .toIso8601String()
            .split('T')[0],
        'time': '11:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Coffee',
        'type': 'expense',
      },
      {
        'category': '🚗 Transportation',
        'amount': -120.0,
        'date': now
            .subtract(const Duration(days: 57))
            .toIso8601String()
            .split('T')[0],
        'time': '09:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'BTS',
        'type': 'expense',
      },
      {
        'category': '🛍️ Shopping',
        'amount': -500.0,
        'date': now
            .subtract(const Duration(days: 58))
            .toIso8601String()
            .split('T')[0],
        'time': '13:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Books',
        'type': 'expense',
      },
      {
        'category': '🍕 Food & Dining',
        'amount': -200.0,
        'date': now
            .subtract(const Duration(days: 59))
            .toIso8601String()
            .split('T')[0],
        'time': '20:00',
        'asset': 'Cash',
        'ledger': 'Personal',
        'remark': 'Snacks',
        'type': 'expense',
      },
    ];

    // Insert sample transactions
    for (final transaction in sampleTransactions) {
      await insertTransaction(transaction);
    }

    // Update balances based on transactions
    await _updateBalanceFromTransactions();

    // Initialize default budgets
    await _initializeDefaultBudgets();

    // Verify data was added
    final finalTransactions = await db.query(_transactionsTable);
    print(
      'Sample data added successfully. Total transactions: ${finalTransactions.length}',
    );

    // Print some sample data for verification
    if (finalTransactions.isNotEmpty) {
      print('Sample transaction: ${finalTransactions.first}');
    }
  }

  /// Initialize default budgets
  Future<void> _initializeDefaultBudgets() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // Check if budgets already exist
    final existingBudgets = await db.query(_budgetsTable);
    if (existingBudgets.isNotEmpty) {
      print('Default budgets already exist, skipping...');
      return;
    }

    // Calculate actual spending from transactions for realistic budget amounts
    final spendingByCategory = await getSpendingByCategory();
    final totalMonthlySpending = spendingByCategory.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    // Create realistic budget plans based on actual spending
    final defaultBudgets = [
      {
        _budgetType: 'weekly',
        _budgetAmount: (totalMonthlySpending / 4.3).clamp(
          1000.0,
          10000.0,
        ), // Weekly budget
        _budgetSpent: 0.0,
        _budgetCategory: null,
        _budgetCreatedAt: now,
        _budgetUpdatedAt: now,
      },
      {
        _budgetType: 'monthly',
        _budgetAmount: totalMonthlySpending.clamp(
          5000.0,
          50000.0,
        ), // Monthly budget
        _budgetSpent: 0.0,
        _budgetCategory: null,
        _budgetCreatedAt: now,
        _budgetUpdatedAt: now,
      },
      {
        _budgetType: 'yearly',
        _budgetAmount: (totalMonthlySpending * 12).clamp(
          60000.0,
          600000.0,
        ), // Yearly budget
        _budgetSpent: 0.0,
        _budgetCategory: null,
        _budgetCreatedAt: now,
        _budgetUpdatedAt: now,
      },
    ];

    // Insert default budgets
    for (final budget in defaultBudgets) {
      await db.insert(_budgetsTable, budget);
    }

    // Insert sample assets and liabilities
    await _insertSampleAssetsAndLiabilities(db);

    print('Default budgets initialized successfully');
  }

  /// Insert sample assets and liabilities
  Future<void> _insertSampleAssetsAndLiabilities(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Sample Assets
    final sampleAssets = [
      {
        _assetName: '🏠 House',
        _assetAmount: 2500000.0,
        _assetCategory: 'Real Estate',
        _assetColor: '#4CAF50',
        _assetCreatedAt: now,
        _assetUpdatedAt: now,
      },
      {
        _assetName: '🚗 Car',
        _assetAmount: 450000.0,
        _assetCategory: 'Vehicle',
        _assetColor: '#2196F3',
        _assetCreatedAt: now,
        _assetUpdatedAt: now,
      },
      {
        _assetName: '💻 Electronics',
        _assetAmount: 150000.0,
        _assetCategory: 'Personal',
        _assetColor: '#FF9800',
        _assetCreatedAt: now,
        _assetUpdatedAt: now,
      },
      {
        _assetName: '📱 Digital Assets',
        _assetAmount: 50000.0,
        _assetCategory: 'Digital',
        _assetColor: '#9C27B0',
        _assetCreatedAt: now,
        _assetUpdatedAt: now,
      },
      {
        _assetName: '💎 Jewelry',
        _assetAmount: 80000.0,
        _assetCategory: 'Personal',
        _assetColor: '#E91E63',
        _assetCreatedAt: now,
        _assetUpdatedAt: now,
      },
    ];

    // Sample Liabilities
    final sampleLiabilities = [
      {
        _liabilityName: '🏠 Mortgage',
        _liabilityAmount: 1800000.0,
        _liabilityCategory: 'Real Estate',
        _liabilityColor: '#F44336',
        _liabilityCreatedAt: now,
        _liabilityUpdatedAt: now,
      },
      {
        _liabilityName: '🚗 Car Loan',
        _liabilityAmount: 320000.0,
        _liabilityCategory: 'Vehicle',
        _liabilityColor: '#FF5722',
        _liabilityCreatedAt: now,
        _liabilityUpdatedAt: now,
      },
      {
        _liabilityName: '💳 Credit Card',
        _liabilityAmount: 45000.0,
        _liabilityCategory: 'Personal',
        _liabilityColor: '#795548',
        _liabilityCreatedAt: now,
        _liabilityUpdatedAt: now,
      },
      {
        _liabilityName: '📚 Student Loan',
        _liabilityAmount: 120000.0,
        _liabilityCategory: 'Education',
        _liabilityColor: '#607D8B',
        _liabilityCreatedAt: now,
        _liabilityUpdatedAt: now,
      },
      {
        _liabilityName: '🏥 Medical Bills',
        _liabilityAmount: 25000.0,
        _liabilityCategory: 'Healthcare',
        _liabilityColor: '#E91E63',
        _liabilityCreatedAt: now,
        _liabilityUpdatedAt: now,
      },
    ];

    // Insert sample assets
    for (final asset in sampleAssets) {
      await db.insert(_assetsTable, asset);
    }

    // Insert sample liabilities
    for (final liability in sampleLiabilities) {
      await db.insert(_liabilitiesTable, liability);
    }

    print('Sample assets and liabilities added successfully');
  }
}
