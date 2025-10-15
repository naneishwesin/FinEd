// lib/services/migration_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'database_service.dart';

class MigrationService {
  static const String _migrationKey = 'migration_completed';

  /// Check if migration has been completed
  static Future<bool> isMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_migrationKey) ?? false;
  }

  /// Mark migration as completed
  static Future<void> markMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationKey, true);
  }

  /// Migrate all data from SharedPreferences to SQLite
  static Future<void> migrateAllData() async {
    if (await isMigrationCompleted()) {
      return; // Migration already completed
    }

    final prefs = await SharedPreferences.getInstance();
    final dbService = DatabaseService();

    try {
      // Migrate transactions
      await _migrateTransactions(prefs, dbService);

      // Migrate balances
      await _migrateBalances(prefs, dbService);

      // Migrate settings
      await _migrateSettings(prefs, dbService);

      // Mark migration as completed
      await markMigrationCompleted();

      print('Migration completed successfully');
    } catch (e) {
      print('Migration failed: $e');
      rethrow;
    }
  }

  /// Migrate transactions from SharedPreferences to SQLite
  static Future<void> _migrateTransactions(
    SharedPreferences prefs,
    DatabaseService dbService,
  ) async {
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      try {
        final List<dynamic> transactionsList = jsonDecode(transactionsJson);
        for (final transaction in transactionsList) {
          final Map<String, dynamic> transactionMap = Map<String, dynamic>.from(
            transaction,
          );

          // Ensure all required fields are present
          transactionMap['category'] ??= '📝 Unknown';
          transactionMap['amount'] ??= 0.0;
          transactionMap['date'] ??= DateTime.now().toIso8601String().split(
            'T',
          )[0];
          transactionMap['time'] ??= '12:00';
          transactionMap['asset'] ??= 'Cash';
          transactionMap['ledger'] ??= 'Personal';
          transactionMap['remark'] ??= 'Migrated from old data';
          transactionMap['type'] ??= (transactionMap['amount'] < 0)
              ? 'expense'
              : 'income';

          await dbService.insertTransaction(transactionMap);
        }
        print('Migrated ${transactionsList.length} transactions');
      } catch (e) {
        print('Error migrating transactions: $e');
      }
    }
  }

  /// Migrate balances from SharedPreferences to SQLite
  static Future<void> _migrateBalances(
    SharedPreferences prefs,
    DatabaseService dbService,
  ) async {
    // Migrate current balance
    final currentBalance = prefs.getDouble('currentBalance') ?? 0.0;
    await dbService.updateBalance('current', currentBalance);

    // Migrate emergency balance
    final emergencyBalance = prefs.getDouble('emergencyBalance') ?? 0.0;
    await dbService.updateBalance('emergency', emergencyBalance);

    // Migrate investment balance
    final investmentBalance = prefs.getDouble('investmentBalance') ?? 0.0;
    await dbService.updateBalance('investment', investmentBalance);

    print(
      'Migrated balances: Current=$currentBalance, Emergency=$emergencyBalance, Investment=$investmentBalance',
    );
  }

  /// Migrate settings from SharedPreferences to SQLite
  static Future<void> _migrateSettings(
    SharedPreferences prefs,
    DatabaseService dbService,
  ) async {
    final keys = prefs.getKeys();

    for (final key in keys) {
      // Skip migration key and transaction data
      if (key == _migrationKey || key == 'transactions') {
        continue;
      }

      final value = prefs.get(key);
      if (value != null) {
        await dbService.setSetting(key, value);
      }
    }

    print('Migrated ${keys.length - 2} settings');
  }

  /// Clear SharedPreferences data after successful migration
  static Future<void> clearOldData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key != _migrationKey) {
        await prefs.remove(key);
      }
    }

    print('Cleared old SharedPreferences data');
  }

  /// Get migration status for debugging
  static Future<Map<String, dynamic>> getMigrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final dbService = DatabaseService();

    return {
      'migration_completed': await isMigrationCompleted(),
      'shared_prefs_keys': prefs.getKeys().length,
      'db_transactions': (await dbService.getAllTransactions()).length,
      'db_current_balance': await dbService.getCurrentBalance(),
      'db_emergency_balance': await dbService.getEmergencyBalance(),
      'db_investment_balance': await dbService.getInvestmentBalance(),
    };
  }
}
