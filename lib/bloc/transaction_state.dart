part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<Map<String, dynamic>> transactions;

  const TransactionLoaded({required this.transactions});

  @override
  List<Object> get props => [transactions];
}

class TransactionSyncing extends TransactionState {
  const TransactionSyncing();
}

class TransactionSyncSuccess extends TransactionState {
  const TransactionSyncSuccess();
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}

