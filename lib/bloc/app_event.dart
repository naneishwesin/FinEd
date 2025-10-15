part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

class AppSyncRequested extends AppEvent {
  const AppSyncRequested();
}

class AppErrorOccurred extends AppEvent {
  final String message;
  
  const AppErrorOccurred(this.message);
  
  @override
  List<Object> get props => [message];
}

