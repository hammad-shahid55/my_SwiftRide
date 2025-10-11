import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swift_ride/Widgets/CustomTextField.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should display label and hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('should show email hint when isEmail is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              controller: controller,
              isEmail: true,
            ),
          ),
        ),
      );

      expect(find.text('example@gmail.com'), findsOneWidget);
    });

    testWidgets('should show password visibility toggle when isPassword is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('should toggle password visibility when eye icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      // Initially should show visibility_off icon
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap the visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // Should now show visibility icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      final key = GlobalKey<CustomTextFieldState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              key: key,
              label: 'Email',
              hintText: 'Enter your email',
              controller: controller,
              isEmail: true,
            ),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextField), 'invalid-email');
      await tester.pump();

      // Validate manually
      final isValid = key.currentState?.validateNow();
      expect(isValid, false);

      // Check error message
      expect(find.text('Enter a valid email (example@gmail.com)'), findsOneWidget);
    });

    testWidgets('should validate password strength', (WidgetTester tester) async {
      final key = GlobalKey<CustomTextFieldState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              key: key,
              label: 'Password',
              hintText: 'Enter your password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      // Enter weak password
      await tester.enterText(find.byType(TextField), 'weak');
      await tester.pump();

      // Validate manually
      final isValid = key.currentState?.validateNow();
      expect(isValid, false);

      // Check error message
      expect(find.text('Password must have upper, lower, digit & symbol'), findsOneWidget);
    });

    testWidgets('should accept valid email', (WidgetTester tester) async {
      final key = GlobalKey<CustomTextFieldState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              key: key,
              label: 'Email',
              hintText: 'Enter your email',
              controller: controller,
              isEmail: true,
            ),
          ),
        ),
      );

      // Enter valid email
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();

      // Validate manually
      final isValid = key.currentState?.validateNow();
      expect(isValid, true);
    });

    testWidgets('should accept valid password', (WidgetTester tester) async {
      final key = GlobalKey<CustomTextFieldState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              key: key,
              label: 'Password',
              hintText: 'Enter your password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      // Enter valid password
      await tester.enterText(find.byType(TextField), 'ValidPass123!');
      await tester.pump();

      // Validate manually
      final isValid = key.currentState?.validateNow();
      expect(isValid, true);
    });

    testWidgets('should show error for empty field', (WidgetTester tester) async {
      final key = GlobalKey<CustomTextFieldState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              key: key,
              label: 'Email',
              hintText: 'Enter your email',
              controller: controller,
            ),
          ),
        ),
      );

      // Leave field empty and validate
      final isValid = key.currentState?.validateNow();
      expect(isValid, false);

      // Pump to update the UI with error message
      await tester.pump();
      
      // Check error message is displayed
      expect(find.text('Email cannot be empty'), findsOneWidget);
    });
  });
}
