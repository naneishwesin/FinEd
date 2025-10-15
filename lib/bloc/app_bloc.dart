import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import '../services/firebase_service.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final DatabaseService _databaseService;
  final ConnectivityService _connectivityService;

  AppBloc({
    required DatabaseService databaseService,
    required ConnectivityService connectivityService,
  }) : _databaseService = databaseService,
       _connectivityService = connectivityService,
       super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppSyncRequested>(_onAppSyncRequested);
    on<AppErrorOccurred>(_onAppErrorOccurred);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    try {
      emit(const AppLoading());

      // Initialize database (access database property to trigger initialization)
      await _databaseService.database;

      // Check connectivity
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        // Try to sync with Firebase
        await _syncWithFirebase();
        emit(const AppLoaded(isOnline: true));
      } else {
        emit(const AppLoaded(isOnline: false));
      }
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onAppSyncRequested(
    AppSyncRequested event,
    Emitter<AppState> emit,
  ) async {
    try {
      emit(const AppSyncing());
      await _syncWithFirebase();
      emit(const AppLoaded(isOnline: true));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  void _onAppErrorOccurred(AppErrorOccurred event, Emitter<AppState> emit) {
    emit(AppError(event.message));
  }

  Future<void> _syncWithFirebase() async {
    try {
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
    } catch (e) {
      print('Firebase sync failed: $e');
      // Continue without sync - app works offline
    }
  }
}
