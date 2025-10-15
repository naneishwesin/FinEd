// lib/services/unified_data_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'connectivity_service.dart';
import 'database_service.dart';
import 'firebase_service.dart';

class UnifiedDataService {
  static final UnifiedDataService _instance = UnifiedDataService._internal();
  factory UnifiedDataService() => _instance;
  UnifiedDataService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();
  final ConnectivityService _connectivityService = ConnectivityService();

  // Sync status
  bool _isSyncing = false;
  final StreamController<bool> _syncStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get syncStatus => _syncStatusController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      await _databaseService.database; // Initialize database
      _syncStatusController.add(false);
    } catch (e) {
      debugPrint('UnifiedDataService initialization failed: $e');
      rethrow;
    }
  }

  // Transaction operations
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      final transactions = await _databaseService.getAllTransactions();

      // Try to sync with Firebase if connected
      if (await _connectivityService.isConnected()) {
        _syncInBackground(() => FirebaseService.saveTransactions(transactions));
      }

      return transactions;
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      rethrow;
    }
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    try {
      final id = await _databaseService.insertTransaction(transaction);

      // Try to sync with Firebase if connected
      if (await _connectivityService.isConnected()) {
        _syncInBackground(
          () => FirebaseService.saveTransactions([transaction]),
        );
      }

      return id;
    } catch (e) {
      debugPrint('Error inserting transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(
    int id,
    Map<String, dynamic> transaction,
  ) async {
    try {
      await _databaseService.updateTransaction(id, transaction);

      // Try to sync with Firebase if connected
      if (await _connectivityService.isConnected()) {
        _syncInBackground(
          () => FirebaseService.updateTransaction(id, transaction),
        );
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _databaseService.deleteTransaction(id);

      // Try to sync with Firebase if connected
      if (await _connectivityService.isConnected()) {
        _syncInBackground(() => FirebaseService.deleteTransaction(id));
      }
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Balance operations
  Future<double> getCurrentBalance() async {
    try {
      return await _databaseService.getCurrentBalance();
    } catch (e) {
      debugPrint('Error getting current balance: $e');
      return 0.0;
    }
  }

  Future<double> getEmergencyBalance() async {
    try {
      return await _databaseService.getEmergencyBalance();
    } catch (e) {
      debugPrint('Error getting emergency balance: $e');
      return 0.0;
    }
  }

  Future<double> getInvestmentBalance() async {
    try {
      return await _databaseService.getInvestmentBalance();
    } catch (e) {
      debugPrint('Error getting investment balance: $e');
      return 0.0;
    }
  }

  // Settings operations
  Future<T?> getSetting<T>(String key) async {
    try {
      return await _databaseService.getSetting<T>(key);
    } catch (e) {
      debugPrint('Error getting setting $key: $e');
      return null;
    }
  }

  Future<void> setSetting<T>(String key, T value) async {
    try {
      await _databaseService.setSetting(key, value);
    } catch (e) {
      debugPrint('Error setting $key: $e');
      rethrow;
    }
  }

  // User profile operations (placeholder - to be implemented)
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      // TODO: Implement getUserProfile in DatabaseService
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> profile) async {
    try {
      // TODO: Implement updateUserProfile in DatabaseService
      debugPrint('User profile update not implemented yet');
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Financial goals operations (placeholder - to be implemented)
  Future<List<Map<String, dynamic>>> getFinancialGoals() async {
    try {
      // TODO: Implement getFinancialGoals in DatabaseService
      return [];
    } catch (e) {
      debugPrint('Error getting financial goals: $e');
      return [];
    }
  }

  Future<int> insertFinancialGoal(Map<String, dynamic> goal) async {
    try {
      return await _databaseService.insertFinancialGoal(goal);
    } catch (e) {
      debugPrint('Error inserting financial goal: $e');
      rethrow;
    }
  }

  Future<void> updateFinancialGoal(int id, Map<String, dynamic> goal) async {
    try {
      await _databaseService.updateFinancialGoal(id, goal);
    } catch (e) {
      debugPrint('Error updating financial goal: $e');
      rethrow;
    }
  }

  Future<void> deleteFinancialGoal(int id) async {
    try {
      await _databaseService.deleteFinancialGoal(id);
    } catch (e) {
      debugPrint('Error deleting financial goal: $e');
      rethrow;
    }
  }

  // Budget operations (placeholder - to be implemented)
  Future<Map<String, dynamic>?> getBudget(String period) async {
    try {
      // TODO: Implement getBudget in DatabaseService
      return null;
    } catch (e) {
      debugPrint('Error getting budget for $period: $e');
      return null;
    }
  }

  Future<void> setBudget(String period, double amount) async {
    try {
      // TODO: Implement setBudget in DatabaseService
      debugPrint('Budget setting not implemented yet');
    } catch (e) {
      debugPrint('Error setting budget for $period: $e');
      rethrow;
    }
  }

  // Reports operations
  Future<Map<String, double>> getSpendingByCategory() async {
    try {
      return await _databaseService.getSpendingByCategory();
    } catch (e) {
      debugPrint('Error getting spending by category: $e');
      return {};
    }
  }

  Future<double> getTotalIncome() async {
    try {
      return await _databaseService.getTotalIncome();
    } catch (e) {
      debugPrint('Error getting total income: $e');
      return 0.0;
    }
  }

  Future<double> getTotalExpenses() async {
    try {
      return await _databaseService.getTotalExpenses();
    } catch (e) {
      debugPrint('Error getting total expenses: $e');
      return 0.0;
    }
  }

  // Manual sync operations
  Future<void> syncWithFirebase() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncStatusController.add(true);

    try {
      if (!await _connectivityService.isConnected()) {
        throw Exception('No internet connection');
      }

      // Sync transactions
      final transactions = await _databaseService.getAllTransactions();
      if (transactions.isNotEmpty) {
        await FirebaseService.saveTransactions(transactions);
      }

      // Sync balances
      final currentBalance = await _databaseService.getCurrentBalance();
      final emergencyBalance = await _databaseService.getEmergencyBalance();
      final investmentBalance = await _databaseService.getInvestmentBalance();

      await FirebaseService.saveBalance('current', currentBalance);
      await FirebaseService.saveBalance('emergency', emergencyBalance);
      await FirebaseService.saveBalance('investment', investmentBalance);

      // Sync settings (placeholder - to be implemented)
      // TODO: Implement getAllSettings in DatabaseService and saveSettings in FirebaseService
      debugPrint('Settings sync not implemented yet');

      debugPrint('Sync with Firebase completed successfully');
    } catch (e) {
      debugPrint('Sync with Firebase failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  Future<List<Map<String, dynamic>>> getInvestments() async {
    try {
      return await _databaseService.getInvestments();
    } catch (e) {
      debugPrint('Error getting investments: $e');
      return [];
    }
  }

  Future<void> updateBalance(String type, double amount) async {
    try {
      await _databaseService.updateBalance(type, amount);
    } catch (e) {
      debugPrint('Error updating balance: $e');
      rethrow;
    }
  }

  // Background sync helper
  void _syncInBackground(Future<void> Function() syncOperation) {
    syncOperation().catchError((e) {
      debugPrint('Background sync failed: $e');
      // Don't rethrow - this is background operation
    });
  }

  // Check if syncing
  bool get isSyncing => _isSyncing;

  // Dispose
  void dispose() {
    _syncStatusController.close();
  }
}
