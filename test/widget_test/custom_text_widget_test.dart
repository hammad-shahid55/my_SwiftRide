import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swift_ride/Widgets/CustomTextWidget.dart';

void main() {
  group('CustomTextWidget Widget Tests', () {
    testWidgets('should display title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: 'Let\'s dive into your account',
            ),
          ),
        ),
      );

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Let\'s dive into your account'), findsOneWidget);
    });

    testWidgets('should display only title when subtitle is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: '',
            ),
          ),
        ),
      );

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text(''), findsNothing);
    });

    testWidgets('should use custom title size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              titleSize: 32,
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Welcome Back!'));
      expect(titleText.style?.fontSize, 32);
    });

    testWidgets('should use custom subtitle size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: 'Let\'s dive into your account',
              subtitleSize: 20,
            ),
          ),
        ),
      );

      final subtitleText = tester.widget<Text>(find.text('Let\'s dive into your account'));
      expect(subtitleText.style?.fontSize, 20);
    });

    testWidgets('should use custom title weight', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              titleWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Welcome Back!'));
      expect(titleText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should use custom subtitle weight', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: 'Let\'s dive into your account',
              subtitleWeight: FontWeight.w500,
            ),
          ),
        ),
      );

      final subtitleText = tester.widget<Text>(find.text('Let\'s dive into your account'));
      expect(subtitleText.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('should use custom title color', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              titleColor: customColor,
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Welcome Back!'));
      expect(titleText.style?.color, customColor);
    });

    testWidgets('should use custom subtitle color', (WidgetTester tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: 'Let\'s dive into your account',
              subtitleColor: customColor,
            ),
          ),
        ),
      );

      final subtitleText = tester.widget<Text>(find.text('Let\'s dive into your account'));
      expect(subtitleText.style?.color, customColor);
    });

    testWidgets('should use custom font family', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: 'Let\'s dive into your account',
              fontFamily: 'Arial',
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Welcome Back!'));
      final subtitleText = tester.widget<Text>(find.text('Let\'s dive into your account'));
      
      expect(titleText.style?.fontFamily, 'Arial');
      expect(subtitleText.style?.fontFamily, 'Arial');
    });

    testWidgets('should use custom text alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: 'Let\'s dive into your account',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Welcome Back!'));
      final subtitleText = tester.widget<Text>(find.text('Let\'s dive into your account'));
      
      expect(titleText.textAlign, TextAlign.center);
      expect(subtitleText.textAlign, TextAlign.center);
    });

    testWidgets('should use custom cross axis alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: 'Let\'s dive into your account',
              alignment: CrossAxisAlignment.center,
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('should use custom spacing between title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: 'Let\'s dive into your account',
              spacing: 20,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, 20);
    });

    testWidgets('should not show spacing when subtitle is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextWidget(
              title: 'Welcome Back!',
              subtitle: '',
              spacing: 20,
            ),
          ),
        ),
      );

      // Should not find any SizedBox for spacing
      expect(find.byType(SizedBox), findsNothing);
    });
  });
}
