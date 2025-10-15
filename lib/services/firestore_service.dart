// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static CollectionReference get _usersCollection =>
      _firestore.collection('users');
  static CollectionReference get _transactionsCollection =>
      _firestore.collection('transactions');
  static CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');
  static CollectionReference get _budgetsCollection =>
      _firestore.collection('budgets');
  static CollectionReference get _assetsCollection =>
      _firestore.collection('assets');
  static CollectionReference get _liabilitiesCollection =>
      _firestore.collection('liabilities');
  static CollectionReference get _goalsCollection =>
      _firestore.collection('financial_goals');
  static CollectionReference get _investmentsCollection =>
      _firestore.collection('investments');
  static CollectionReference get _emergencyFundsCollection =>
      _firestore.collection('emergency_funds');

  // User document reference
  static DocumentReference get _currentUserDoc {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _usersCollection.doc(user.uid);
  }

  // Helper method to get user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Helper method to check authentication
  static bool get isAuthenticated => _auth.currentUser != null;

  // ==================== TRANSACTION OPERATIONS ====================

  /// Add a new transaction
  static Future<String> addTransaction(Map<String, dynamic> transaction) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final docRef = await _transactionsCollection.add({
      ...transaction,
      'userId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Get all transactions for current user
  static Future<List<Map<String, dynamic>>> getAllTransactions() async {
    if (!isAuthenticated) return [];

    final snapshot = await _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Get transactions by date range
  static Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (!isAuthenticated) return [];

    final snapshot = await _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .where(
          'date',
          isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0],
        )
        .where(
          'date',
          isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0],
        )
        .orderBy('date', descending: true)
        .orderBy('time', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Update a transaction
  static Future<void> updateTransaction(
    String id,
    Map<String, dynamic> transaction,
  ) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _transactionsCollection.doc(id).update({
      ...transaction,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a transaction
  static Future<void> deleteTransaction(String id) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _transactionsCollection.doc(id).delete();
  }

  /// Get transactions by type (income/expense)
  static Future<List<Map<String, dynamic>>> getTransactionsByType(
    String type,
  ) async {
    if (!isAuthenticated) return [];

    final snapshot = await _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Get spending by category
  static Future<Map<String, double>> getSpendingByCategory() async {
    if (!isAuthenticated) return {};

    final snapshot = await _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'expense')
        .get();

    final Map<String, double> spendingByCategory = {};

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = data['category'] as String;
      final amount = (data['amount'] as num).abs().toDouble();

      spendingByCategory[category] =
          (spendingByCategory[category] ?? 0.0) + amount;
    }

    return spendingByCategory;
  }

  // ==================== BALANCE OPERATIONS ====================

  /// Get current balance
  static Future<double> getCurrentBalance() async {
    if (!isAuthenticated) return 0.0;

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return (data?['currentBalance'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  /// Get emergency balance
  static Future<double> getEmergencyBalance() async {
    if (!isAuthenticated) return 0.0;

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return (data?['emergencyBalance'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  /// Get investment balance
  static Future<double> getInvestmentBalance() async {
    if (!isAuthenticated) return 0.0;

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return (data?['investmentBalance'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  /// Update balance
  static Future<void> updateBalance(String type, double amount) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _currentUserDoc.set({
      '${type}Balance': amount,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Recalculate all balances from transactions
  static Future<void> recalculateAllBalances() async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    // Get all transactions
    final transactions = await getAllTransactions();

    // Calculate current balance
    double currentBalance = 0.0;
    for (final transaction in transactions) {
      currentBalance += (transaction['amount'] as num).toDouble();
    }

    // Calculate emergency fund balance
    final emergencyFunds = await getAllEmergencyFunds();
    double emergencyBalance = 0.0;
    for (final fund in emergencyFunds) {
      emergencyBalance += (fund['current_amount'] as num).toDouble();
    }

    // Calculate investment balance
    final investments = await getAllInvestments();
    double investmentBalance = 0.0;
    for (final investment in investments) {
      final quantity = (investment['quantity'] as num).toDouble();
      final currentPrice =
          (investment['current_price'] as num?)?.toDouble() ??
          (investment['purchase_price'] as num).toDouble();
      investmentBalance += quantity * currentPrice;
    }

    // Update balances
    await _currentUserDoc.set({
      'currentBalance': currentBalance,
      'emergencyBalance': emergencyBalance,
      'investmentBalance': investmentBalance,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ==================== CATEGORY OPERATIONS ====================

  /// Get all categories
  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    final snapshot = await _categoriesCollection.get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Get categories by type
  static Future<List<Map<String, dynamic>>> getCategoriesByType(
    String type,
  ) async {
    final snapshot = await _categoriesCollection
        .where('type', isEqualTo: type)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Add a new category
  static Future<String> addCategory(Map<String, dynamic> category) async {
    final docRef = await _categoriesCollection.add({
      ...category,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // ==================== BUDGET OPERATIONS ====================

  /// Get all budgets
  static Future<List<Map<String, dynamic>>> getAllBudgets() async {
    if (!isAuthenticated) return [];

    final snapshot = await _budgetsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('type')
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Get budget by type
  static Future<Map<String, dynamic>?> getBudgetByType(String type) async {
    if (!isAuthenticated) return null;

    final snapshot = await _budgetsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('type', isEqualTo: type)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return {
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data() as Map<String, dynamic>,
      };
    }
    return null;
  }

  /// Add or update budget
  static Future<String> addBudget(Map<String, dynamic> budget) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final docRef = await _budgetsCollection.add({
      ...budget,
      'userId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Update budget
  static Future<void> updateBudget(
    String id,
    Map<String, dynamic> budget,
  ) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _budgetsCollection.doc(id).update({
      ...budget,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== ASSET OPERATIONS ====================

  /// Get all assets
  static Future<List<Map<String, dynamic>>> getAllAssets() async {
    if (!isAuthenticated) return [];

    final snapshot = await _assetsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Add asset
  static Future<String> addAsset(Map<String, dynamic> asset) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final docRef = await _assetsCollection.add({
      ...asset,
      'userId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Update asset
  static Future<void> updateAsset(String id, Map<String, dynamic> asset) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _assetsCollection.doc(id).update({
      ...asset,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete asset
  static Future<void> deleteAsset(String id) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _assetsCollection.doc(id).delete();
  }

  /// Get total assets
  static Future<double> getTotalAssets() async {
    if (!isAuthenticated) return 0.0;

    final snapshot = await _assetsCollection
        .where('userId', isEqualTo: currentUserId)
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        total += (data['amount'] as num).toDouble();
      }
    }
    return total;
  }

  // ==================== LIABILITY OPERATIONS ====================

  /// Get all liabilities
  static Future<List<Map<String, dynamic>>> getAllLiabilities() async {
    if (!isAuthenticated) return [];

    final snapshot = await _liabilitiesCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Add liability
  static Future<String> addLiability(Map<String, dynamic> liability) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final docRef = await _liabilitiesCollection.add({
      ...liability,
      'userId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Update liability
  static Future<void> updateLiability(
    String id,
    Map<String, dynamic> liability,
  ) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _liabilitiesCollection.doc(id).update({
      ...liability,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete liability
  static Future<void> deleteLiability(String id) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _liabilitiesCollection.doc(id).delete();
  }

  /// Get total liabilities
  static Future<double> getTotalLiabilities() async {
    if (!isAuthenticated) return 0.0;

    final snapshot = await _liabilitiesCollection
        .where('userId', isEqualTo: currentUserId)
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        total += (data['amount'] as num).toDouble();
      }
    }
    return total;
  }

  // ==================== FINANCIAL GOALS OPERATIONS ====================

  /// Get all financial goals
  static Future<List<Map<String, dynamic>>> getAllFinancialGoals() async {
    if (!isAuthenticated) return [];

    final snapshot = await _goalsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('priority')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Add financial goal
  static Future<String> addFinancialGoal(Map<String, dynamic> goal) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final docRef = await _goalsCollection.add({
      ...goal,
      'userId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Update financial goal
  static Future<void> updateFinancialGoal(
    String id,
    Map<String, dynamic> goal,
  ) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _goalsCollection.doc(id).update({
      ...goal,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete financial goal
  static Future<void> deleteFinancialGoal(String id) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _goalsCollection.doc(id).delete();
  }

  // ==================== INVESTMENT OPERATIONS ====================

  /// Get all investments
  static Future<List<Map<String, dynamic>>> getAllInvestments() async {
    if (!isAuthenticated) return [];

    final snapshot = await _investmentsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Add investment
  static Future<String> addInvestment(Map<String, dynamic> investment) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final docRef = await _investmentsCollection.add({
      ...investment,
      'userId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Update investment
  static Future<void> updateInvestment(
    String id,
    Map<String, dynamic> investment,
  ) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _investmentsCollection.doc(id).update({
      ...investment,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete investment
  static Future<void> deleteInvestment(String id) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _investmentsCollection.doc(id).delete();
  }

  // ==================== EMERGENCY FUNDS OPERATIONS ====================

  /// Get all emergency funds
  static Future<List<Map<String, dynamic>>> getAllEmergencyFunds() async {
    if (!isAuthenticated) return [];

    final snapshot = await _emergencyFundsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('priority')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Add emergency fund
  static Future<String> addEmergencyFund(
    Map<String, dynamic> emergencyFund,
  ) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final docRef = await _emergencyFundsCollection.add({
      ...emergencyFund,
      'userId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Update emergency fund
  static Future<void> updateEmergencyFund(
    String id,
    Map<String, dynamic> emergencyFund,
  ) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _emergencyFundsCollection.doc(id).update({
      ...emergencyFund,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete emergency fund
  static Future<void> deleteEmergencyFund(String id) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _emergencyFundsCollection.doc(id).delete();
  }

  // ==================== SETTINGS OPERATIONS ====================

  /// Get user settings
  static Future<Map<String, dynamic>> getUserSettings() async {
    if (!isAuthenticated) return _getDefaultSettings();

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['settings'] as Map<String, dynamic>? ??
          _getDefaultSettings();
    }
    return _getDefaultSettings();
  }

  /// Update user settings
  static Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    await _currentUserDoc.set({
      'settings': settings,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get setting by key
  static Future<T?> getSetting<T>(String key) async {
    final settings = await getUserSettings();
    return settings[key] as T?;
  }

  /// Set setting by key
  static Future<void> setSetting(String key, dynamic value) async {
    final settings = await getUserSettings();
    settings[key] = value;
    await updateUserSettings(settings);
  }

  // ==================== STATISTICS OPERATIONS ====================

  /// Get total income
  static Future<double> getTotalIncome() async {
    if (!isAuthenticated) return 0.0;

    final snapshot = await _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'income')
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        total += (data['amount'] as num).toDouble();
      }
    }
    return total;
  }

  /// Get total expenses
  static Future<double> getTotalExpenses() async {
    if (!isAuthenticated) return 0.0;

    final snapshot = await _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'expense')
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        total += (data['amount'] as num).abs().toDouble();
      }
    }
    return total;
  }

  /// Get monthly transactions
  static Future<List<Map<String, dynamic>>> getMonthlyTransactions(
    int year,
    int month,
  ) async {
    if (!isAuthenticated) return [];

    final startDate = DateTime(year, month, 1).toIso8601String().split('T')[0];
    final endDate = DateTime(
      year,
      month + 1,
      0,
    ).toIso8601String().split('T')[0];

    return await getTransactionsByDateRange(
      DateTime.parse(startDate),
      DateTime.parse(endDate),
    );
  }

  // ==================== REAL-TIME LISTENERS ====================

  /// Get transactions stream
  static Stream<List<Map<String, dynamic>>> getTransactionsStream() {
    if (!isAuthenticated) return Stream.value([]);

    return _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList(),
        );
  }

  /// Get user data stream
  static Stream<DocumentSnapshot> getUserDataStream() {
    if (!isAuthenticated) throw Exception('User not authenticated');
    return _currentUserDoc.snapshots();
  }

  // ==================== UTILITY METHODS ====================

  /// Initialize default categories
  static Future<void> initializeDefaultCategories() async {
    final existingCategories = await getAllCategories();
    if (existingCategories.isNotEmpty) return;

    final defaultCategories = [
      {
        'name': '🍕 Food & Dining',
        'icon': '🍕',
        'color': '#FF6B6B',
        'type': 'expense',
        'isDefault': true,
      },
      {
        'name': '🚗 Transportation',
        'icon': '🚗',
        'color': '#4ECDC4',
        'type': 'expense',
        'isDefault': true,
      },
      {
        'name': '🛍️ Shopping',
        'icon': '🛍️',
        'color': '#45B7D1',
        'type': 'expense',
        'isDefault': true,
      },
      {
        'name': '🏠 Housing',
        'icon': '🏠',
        'color': '#96CEB4',
        'type': 'expense',
        'isDefault': true,
      },
      {
        'name': '💼 Salary',
        'icon': '💼',
        'color': '#FFEAA7',
        'type': 'income',
        'isDefault': true,
      },
      {
        'name': '🎁 Allowance',
        'icon': '🎁',
        'color': '#DDA0DD',
        'type': 'income',
        'isDefault': true,
      },
    ];

    for (final category in defaultCategories) {
      await addCategory(category);
    }
  }

  /// Get default settings
  static Map<String, dynamic> _getDefaultSettings() {
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

  /// Clear all user data (for testing)
  static Future<void> clearAllUserData() async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    // Delete all user collections
    final collections = [
      _transactionsCollection,
      _budgetsCollection,
      _assetsCollection,
      _liabilitiesCollection,
      _goalsCollection,
      _investmentsCollection,
      _emergencyFundsCollection,
    ];

    for (final collection in collections) {
      final snapshot = await collection
          .where('userId', isEqualTo: currentUserId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    // Reset user document
    await _currentUserDoc.set({
      'currentBalance': 0.0,
      'emergencyBalance': 0.0,
      'investmentBalance': 0.0,
      'settings': _getDefaultSettings(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
