import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/assets_page.dart';
import '../pages/bills_page.dart';
import '../pages/bookmarks_page.dart';
import '../pages/budget_management_page.dart';
import '../pages/cash_records_page.dart';
import '../pages/digital_wallet_page.dart';
import '../pages/financial_goals_page.dart';
import '../pages/home_page.dart';
import '../pages/quick_calculator_page.dart';
import '../pages/reports_page.dart';
import '../pages/settings_page.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/bills',
        name: 'bills',
        builder: (context, state) => const BillsPage(),
      ),
      GoRoute(
        path: '/assets',
        name: 'assets',
        builder: (context, state) => const AssetsPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/budget-management',
        name: 'budget-management',
        builder: (context, state) => const BudgetManagementPage(),
      ),
      GoRoute(
        path: '/financial-goals',
        name: 'financial-goals',
        builder: (context, state) => const FinancialGoalsPage(),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: '/digital-wallet',
        name: 'digital-wallet',
        builder: (context, state) => DigitalWalletPage(),
      ),
      GoRoute(
        path: '/quick-calculator',
        name: 'quick-calculator',
        builder: (context, state) => const QuickCalculatorPage(),
      ),
      GoRoute(
        path: '/bookmarks',
        name: 'bookmarks',
        builder: (context, state) => const BookmarksPage(),
      ),
      GoRoute(
        path: '/cash-records',
        name: 'cash-records',
        builder: (context, state) {
          return const CashRecordsPage();
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}

// Extension for easier navigation
extension AppNavigation on BuildContext {
  void goToHome() => go('/');
  void goToBills() => go('/bills');
  void goToAssets() => go('/assets');
  void goToSettings() => go('/settings');
  void goToBudgetManagement() => go('/budget-management');
  void goToFinancialGoals() => go('/financial-goals');
  void goToReports() => go('/reports');
  void goToDigitalWallet() => go('/digital-wallet');
  void goToQuickCalculator() => go('/quick-calculator');
  void goToBookmarks() => go('/bookmarks');
  void goToCashRecords(List<Map<String, dynamic>> transactions) =>
      go('/cash-records', extra: transactions);
}
