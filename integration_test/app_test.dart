import 'package:expense_tracker/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Expense Tracker Integration Tests', () {
    testWidgets(
      'Complete user flow: Add transaction -> View in calendar -> Edit -> Delete',
      (WidgetTester tester) async {
        // Start the app
        app.main();
        await tester.pumpAndSettle();

        // 1. Navigate to Bills page
        await tester.tap(find.text('Bills'));
        await tester.pumpAndSettle();

        // 2. Add a new transaction
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Fill in transaction details
        await tester.enterText(
          find.byType(TextField).first,
          'Test Transaction',
        );
        await tester.enterText(find.byType(TextField).at(1), '100.0');

        // Select category
        await tester.tap(find.text('Category'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();

        // Save transaction
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        // 3. Verify transaction appears in calendar
        expect(find.text('Test Transaction'), findsOneWidget);

        // 4. Navigate to Home page to check balance update
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();

        // Verify balance has been updated (this would depend on your implementation)
        expect(find.text('Current Balance'), findsOneWidget);

        // 5. Navigate back to Bills page
        await tester.tap(find.text('Bills'));
        await tester.pumpAndSettle();

        // 6. Edit the transaction
        await tester.tap(find.text('Test Transaction'));
        await tester.pumpAndSettle();

        // Modify the amount
        await tester.enterText(find.byType(TextField).at(1), '150.0');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // 7. Verify the change
        expect(find.text('Test Transaction'), findsOneWidget);

        // 8. Delete the transaction
        await tester.tap(find.text('Test Transaction'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        // Confirm deletion
        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle();

        // 9. Verify transaction is removed
        expect(find.text('Test Transaction'), findsNothing);
      },
    );

    testWidgets('Budget management flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Budget Management
      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();

      // Verify budget management page elements
      expect(find.text('Weekly Budget'), findsOneWidget);
      expect(find.text('Monthly Budget'), findsOneWidget);
      expect(find.text('Yearly Budget'), findsOneWidget);

      // Test budget type switching
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      // Verify monthly view is active
      expect(find.text('Monthly Budget'), findsOneWidget);
    });

    testWidgets('Assets page visualization', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Assets page
      await tester.tap(find.text('Assets'));
      await tester.pumpAndSettle();

      // Verify assets page elements
      expect(find.text('Assets'), findsOneWidget);
      expect(find.text('Liabilities'), findsOneWidget);

      // Test adding new asset
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill asset details
      await tester.enterText(find.byType(TextField).first, 'Test Asset');
      await tester.enterText(find.byType(TextField).at(1), '5000.0');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify asset was added
      expect(find.text('Test Asset'), findsOneWidget);
    });
  });
}

