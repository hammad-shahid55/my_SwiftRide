import 'package:swift_ride/Services/SimpleEmailService.dart';
import 'package:swift_ride/Services/EmailConfig.dart';

/// Email Test Service for SwiftRide
/// 
/// This service helps you test your email configuration
/// before deploying to production.
class EmailTestService {
  
  /// Test email configuration and send a test email
  static Future<EmailTestResult> testEmailConfiguration({
    String? testEmail,
  }) async {
    final result = EmailTestResult();
    
    try {
      // Check configuration
      result.configurationValid = EmailConfig.isEmailConfigured;
      result.configurationMessage = EmailConfig.configurationStatus;
      result.setupInstructions = EmailConfig.setupInstructions;
      
      if (!result.configurationValid) {
        result.success = false;
        result.message = 'Email service not configured. Please update EmailConfig.dart';
        return result;
      }
      
      // Test email sending
      final testEmailAddress = testEmail ?? 'test@example.com';
      final testResult = await SimpleEmailService.sendBookingConfirmation(
        userEmail: testEmailAddress,
        userName: 'Test User',
        fromCity: 'Karachi',
        toCity: 'Lahore',
        seats: 2,
        totalPrice: 5000,
        rideTime: DateTime.now().add(Duration(days: 1)).toIso8601String(),
        bookingId: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
      );
      
      result.success = testResult;
      result.message = testResult 
          ? '✅ Test email sent successfully to $testEmailAddress'
          : '❌ Failed to send test email. Check your configuration and API keys.';
      
    } catch (e) {
      result.success = false;
      result.message = '❌ Error testing email configuration: $e';
    }
    
    return result;
  }
  
  /// Get configuration status without sending test email
  static EmailTestResult getConfigurationStatus() {
    final result = EmailTestResult();
    result.configurationValid = EmailConfig.isEmailConfigured;
    result.configurationMessage = EmailConfig.configurationStatus;
    result.setupInstructions = EmailConfig.setupInstructions;
    result.success = result.configurationValid;
    result.message = result.configurationValid 
        ? '✅ Email service is configured'
        : '⚠️ Email service needs configuration';
    
    return result;
  }
  
  /// Print configuration status to console
  static void printConfigurationStatus() {
    final status = getConfigurationStatus();
    print('\n📧 EMAIL CONFIGURATION STATUS');
    print('================================');
    print('Status: ${status.configurationMessage}');
    print('Valid: ${status.configurationValid ? "✅ Yes" : "❌ No"}');
    print('Service: ${EmailConfig.emailService}');
    print('\nSetup Instructions:');
    print(status.setupInstructions);
    print('================================\n');
  }
}

/// Result of email configuration test
class EmailTestResult {
  bool success = false;
  String message = '';
  bool configurationValid = false;
  String configurationMessage = '';
  String setupInstructions = '';
  
  @override
  String toString() {
    return '''
Email Test Result:
- Success: ${success ? "✅" : "❌"}
- Message: $message
- Configuration Valid: ${configurationValid ? "✅" : "❌"}
- Configuration Message: $configurationMessage
''';
  }
}
