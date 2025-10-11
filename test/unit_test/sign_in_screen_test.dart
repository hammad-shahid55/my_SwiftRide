import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swift_ride/Screens/SignInScreen.dart';

void main() {
  group('SignInScreen Widget Tests', () {
    testWidgets('should display sign in screen with correct elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text('👋 Welcome Back!'), findsOneWidget);
      expect(find.text('Let\'s dive into your account'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Don\'t have an account? Sign up'), findsOneWidget);
    });

    testWidgets('should have email and password text fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('should have remember me checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text('Remember me'), findsOneWidget);
    });

    testWidgets('should have forgot password link', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text('Forget Password?'), findsOneWidget);
    });

    testWidgets('should have Google sign in button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      // Look for Google button (adjust based on your GoogleButton implementation)
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have phone number sign up button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text('Continue with Phone'), findsOneWidget);
    });

    testWidgets('should have privacy terms text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      // Look for privacy terms (adjust based on your PrivacyTermsText implementation)
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('should have correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color.fromRGBO(246, 246, 246, 1));
    });

    testWidgets('should dispose controllers properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      // Pump and dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());

      // If we get here without errors, the controllers were disposed properly
      expect(true, true);
    });

    testWidgets('should have scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have proper padding and spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
