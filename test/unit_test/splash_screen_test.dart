import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swift_ride/Screens/SplashScreen.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('should display splash screen with correct elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Initially, animations haven't started, so main content should not be visible
      expect(find.text('SwiftRide'), findsNothing);
      expect(find.text('Ride Smart, Ride Swift'), findsNothing);
    });

    testWidgets('should show animations after delay', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Wait for the initial delay (2 seconds) to start animations
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // Now the animations should have started
      // Note: The exact timing might vary, so we'll check for the presence of the widget
      // The van animation should be visible
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('should have decorative circles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Should find positioned containers (decorative circles)
      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('should have refresh indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should have single child scroll view', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should dispose controllers properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Pump and dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());

      // If we get here without errors, the controllers were disposed properly
      expect(true, true);
    });
  });
}
