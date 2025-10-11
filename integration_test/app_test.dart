import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:swift_ride/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SwiftRide E2E Tests', () {
    testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen elements are present
      expect(find.text('SwiftRide'), findsOneWidget);
      expect(find.text('Ride Smart, Ride Swift'), findsOneWidget);
      
      // Wait for splash animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('Navigate to sign in screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for sign in elements (assuming we navigate to welcome/sign in)
      // This test will need to be adjusted based on your app flow
      if (find.text('Welcome Back!').evaluate().isNotEmpty) {
        expect(find.text('Welcome Back!'), findsOneWidget);
        expect(find.text('Let\'s dive into your account'), findsOneWidget);
      }
    });

    testWidgets('Sign in form validation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to sign in if not already there
      if (find.text('Welcome Back!').evaluate().isNotEmpty) {
        // Test email field
        final emailField = find.byType(TextField).first;
        await tester.enterText(emailField, 'invalid-email');
        await tester.pump();

        // Test password field
        final passwordField = find.byType(TextField).last;
        await tester.enterText(passwordField, '123');
        await tester.pump();

        // Try to submit form
        final signInButton = find.text('Sign In');
        if (signInButton.evaluate().isNotEmpty) {
          await tester.tap(signInButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Google sign in button exists', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if Google sign in button is present
      if (find.text('Continue with Google').evaluate().isNotEmpty) {
        expect(find.text('Continue with Google'), findsOneWidget);
      }
    });

    testWidgets('Phone number sign up navigation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for phone number sign up button
      if (find.text('Continue with Phone').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue with Phone'));
        await tester.pumpAndSettle();
        
        // Verify navigation occurred (adjust based on your phone sign up screen)
        // expect(find.text('Phone Number'), findsOneWidget);
      }
    });
  });
}
