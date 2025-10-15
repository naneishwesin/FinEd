part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class TransactionLoadRequested extends TransactionEvent {
  const TransactionLoadRequested();
}

class TransactionAddRequested extends TransactionEvent {
  final Map<String, dynamic> transaction;

  const TransactionAddRequested(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class TransactionUpdateRequested extends TransactionEvent {
  final int id;
  final Map<String, dynamic> transaction;

  const TransactionUpdateRequested(this.id, this.transaction);

  @override
  List<Object> get props => [id, transaction];
}

class TransactionDeleteRequested extends TransactionEvent {
  final int id;

  const TransactionDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class TransactionSyncRequested extends TransactionEvent {
  const TransactionSyncRequested();
}

