import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/database_service.dart';
import '../services/firebase_service.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final DatabaseService _databaseService;

  TransactionBloc({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService,
       super(const TransactionInitial()) {
    on<TransactionLoadRequested>(_onTransactionLoadRequested);
    on<TransactionAddRequested>(_onTransactionAddRequested);
    on<TransactionUpdateRequested>(_onTransactionUpdateRequested);
    on<TransactionDeleteRequested>(_onTransactionDeleteRequested);
    on<TransactionSyncRequested>(_onTransactionSyncRequested);
  }

  Future<void> _onTransactionLoadRequested(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());

      final transactions = await _databaseService.getAllTransactions();

      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onTransactionAddRequested(
    TransactionAddRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());

      // Add to local database
      await _databaseService.insertTransaction(event.transaction);

      // Try to sync with Firebase
      try {
        await FirebaseService.saveTransactions([event.transaction]);
      } catch (e) {
        // Firebase sync failed, but local save succeeded
        print('Firebase sync failed: $e');
      }

      // Reload transactions
      add(const TransactionLoadRequested());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onTransactionUpdateRequested(
    TransactionUpdateRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());

      // Update in local database
      await _databaseService.updateTransaction(event.id, event.transaction);

      // Try to sync with Firebase
      try {
        await FirebaseService.updateTransaction(event.id, event.transaction);
      } catch (e) {
        print('Firebase sync failed: $e');
      }

      // Reload transactions
      add(const TransactionLoadRequested());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onTransactionDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());

      // Delete from local database
      await _databaseService.deleteTransaction(event.id);

      // Try to sync with Firebase
      try {
        await FirebaseService.deleteTransaction(event.id);
      } catch (e) {
        print('Firebase sync failed: $e');
      }

      // Reload transactions
      add(const TransactionLoadRequested());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onTransactionSyncRequested(
    TransactionSyncRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionSyncing());

      final transactions = await _databaseService.getAllTransactions();

      await FirebaseService.saveTransactions(transactions);

      emit(const TransactionSyncSuccess());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
