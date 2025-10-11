import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swift_ride/Widgets/MainButton.dart';

void main() {
  group('MainButton Widget Tests', () {
    testWidgets('should display button with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainButton(
              text: 'Sign In',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainButton(
              text: 'Sign In',
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(buttonPressed, true);
    });

    testWidgets('should use custom background color when provided', (WidgetTester tester) async {
      const customColor = Color.fromRGBO(123, 61, 244, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainButton(
              text: 'Sign In',
              backgroundColor: customColor,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('should use gradient when provided', (WidgetTester tester) async {
      const customGradient = LinearGradient(
        colors: [Colors.red, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainButton(
              text: 'Sign In',
              gradient: customGradient,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, customGradient);
    });

    testWidgets('should use default gradient when no background color or gradient provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainButton(
              text: 'Sign In',
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
      expect(decoration.color, isNull);
    });

    testWidgets('should use custom text color when provided', (WidgetTester tester) async {
      const customTextColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainButton(
              text: 'Sign In',
              textColor: customTextColor,
              onPressed: () {},
            ),
          ),
        ),
      );

      final textButton = tester.widget<TextButton>(find.byType(TextButton));
      expect(textButton.style?.foregroundColor?.resolve({}), customTextColor);
    });

    testWidgets('should have correct button dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainButton(
              text: 'Sign In',
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, double.infinity);
      expect(container.constraints?.minHeight, 52);
    });

    testWidgets('should have rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainButton(
              text: 'Sign In',
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });
  });
}
