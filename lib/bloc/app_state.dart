part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {
  const AppInitial();
}

class AppLoading extends AppState {
  const AppLoading();
}

class AppLoaded extends AppState {
  final bool isOnline;
  
  const AppLoaded({required this.isOnline});
  
  @override
  List<Object> get props => [isOnline];
}

class AppSyncing extends AppState {
  const AppSyncing();
}

class AppError extends AppState {
  final String message;
  
  const AppError(this.message);
  
  @override
  List<Object> get props => [message];
}

