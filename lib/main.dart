import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/app_bloc.dart';
import 'bloc/transaction_bloc.dart';
import 'main_app.dart';
import 'pages/auth_page.dart';
import 'pages/tutorial_guide_page.dart';
import 'pages/welcome_onboarding_page.dart';
import 'services/app_flow_service.dart';
import 'services/connectivity_service.dart';
import 'services/database_service.dart';
import 'services/enhanced_error_handler.dart';
import 'services/firebase_service.dart';
import 'services/migration_service.dart';
import 'services/notification_service.dart';
import 'services/performance_optimization_service.dart';
import 'services/theme_service.dart';
import 'services/tutorial_service.dart';
import 'services/unified_data_service.dart';
import 'utils/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Continue without Firebase - app will work in offline mode
  }

  // Setup global error handling
  EnhancedErrorHandler.setupGlobalErrorHandler();

  // Start performance monitoring
  PerformanceOptimizationService().startMonitoring();

  // Initialize services
  await NotificationService.init();
  await TutorialService.init();

  // Initialize unified data service
  final unifiedDataService = UnifiedDataService();
  final databaseService = DatabaseService();
  final firebaseService = FirebaseService();
  final connectivityService = ConnectivityService();

  try {
    await unifiedDataService.initialize(); // Initialize unified service
    await MigrationService.migrateAllData(); // Migrate existing data
    await databaseService.addSampleData(); // Add sample data for testing
    print('Unified data service initialized and migration completed');
  } catch (e) {
    print('Service initialization failed: $e');
    // Continue without services - app will work with limited functionality
  }

  runApp(
    MyApp(
      databaseService: databaseService,
      firebaseService: firebaseService,
      connectivityService: connectivityService,
      unifiedDataService: unifiedDataService,
    ),
  );
}

class MyApp extends StatefulWidget {
  final DatabaseService databaseService;
  final FirebaseService firebaseService;
  final ConnectivityService connectivityService;
  final UnifiedDataService unifiedDataService;

  const MyApp({
    super.key,
    required this.databaseService,
    required this.firebaseService,
    required this.connectivityService,
    required this.unifiedDataService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    try {
      final themeString =
          await widget.databaseService.getSetting<String>('theme') ?? 'system';
      final language =
          await widget.databaseService.getSetting<String>('language') ??
          'English';

      setState(() {
        switch (themeString) {
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          default:
            _themeMode = ThemeMode.system;
        }
        _selectedLanguage = language;
      });
    } catch (e) {
      print('Error loading theme settings: $e');
    }
  }

  void updateTheme(ThemeMode newThemeMode) {
    setState(() {
      _themeMode = newThemeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>(
          create: (context) => AppBloc(
            databaseService: widget.databaseService,
            connectivityService: widget.connectivityService,
          )..add(const AppStarted()),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) =>
              TransactionBloc(databaseService: widget.databaseService),
        ),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Expense Tracker',
            theme: ThemeService().lightTheme,
            darkTheme: ThemeService().darkTheme,
            themeMode: _themeMode,
            home: StreamBuilder(
              stream: FirebaseService.authStateChanges,
              builder: (context, snapshot) {
                // Show loading while checking auth state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // Check if user is authenticated
                if (snapshot.hasData && snapshot.data != null) {
                  // User is authenticated, check if they need tutorial
                  return FutureBuilder<bool>(
                    future: AppFlowService.isTutorialCompleted(),
                    builder: (context, tutorialSnapshot) {
                      if (tutorialSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      // If tutorial not completed, show tutorial
                      if (!tutorialSnapshot.data!) {
                        return const TutorialGuidePage();
                      }

                      // If tutorial completed, show main app
                      return MainApp(onThemeChanged: updateTheme);
                    },
                  );
                }

                // User not authenticated, check if they've seen welcome
                return FutureBuilder<bool>(
                  future: AppFlowService.isWelcomeCompleted(),
                  builder: (context, welcomeSnapshot) {
                    if (welcomeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    // If welcome not completed, show welcome onboarding
                    if (!welcomeSnapshot.data!) {
                      return const WelcomeOnboardingPage();
                    }

                    // If welcome completed, show auth page
                    return const AuthPage();
                  },
                );
              },
            ),
            builder: (context, child) {
              return BlocListener<AppBloc, AppState>(
                listener: (context, state) {
                  if (state is AppError) {
                    ErrorHandler.showError(context, state.message);
                  }
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
