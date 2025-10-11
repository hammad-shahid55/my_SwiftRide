import 'package:flutter_test/flutter_test.dart';

/// Test configuration and utilities for SwiftRide tests
class TestConfig {
  /// Default test timeout duration
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  /// Default pump duration for animations
  static const Duration defaultPumpDuration = Duration(milliseconds: 100);
  
  /// Test data constants
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'TestPass123!';
  static const String testInvalidEmail = 'invalid-email';
  static const String testWeakPassword = 'weak';
  
  /// Helper method to pump and settle with default duration
  static Future<void> pumpAndSettle(WidgetTester tester, {Duration? duration}) async {
    await tester.pumpAndSettle(duration ?? defaultPumpDuration);
  }
  
  /// Helper method to pump with default duration
  static Future<void> pump(WidgetTester tester, {Duration? duration}) async {
    await tester.pump(duration ?? defaultPumpDuration);
  }
}

/// Test data factory for creating test objects
class TestDataFactory {
  /// Create a test user email
  static String createTestEmail({String? suffix}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'test$timestamp${suffix ?? ''}@example.com';
  }
  
  /// Create a test password
  static String createTestPassword() {
    return 'TestPass123!';
  }
  
  /// Create a test phone number
  static String createTestPhoneNumber() {
    return '+1234567890';
  }
}
