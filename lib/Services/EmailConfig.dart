import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Email Configuration for SwiftRide
/// 
/// This file contains configuration options for email notifications.
/// Choose one of the email services below and configure it properly.
/// 
/// IMPORTANT: Replace the placeholder values with your actual API keys and settings.

class EmailConfig {
  // ========================================
  // EMAIL SERVICE CONFIGURATION
  // ========================================
  
  /// Choose your email service provider
  /// Options: 'resend', 'sendgrid', 'mailgun', 'emailjs', 'webhook', 'none'
  static const String emailService = 'resend'; // Change this to your preferred service
  
  // ========================================
  // RESEND CONFIGURATION (Recommended)
  // ========================================
  /// Get your API key from: https://resend.com/api-keys
  /// This will use environment variable if available, otherwise fallback to hardcoded value
  static String get resendApiKey {
    // Try to get from .env file first
    final dotenvApiKey = dotenv.env['RESEND_API_KEY'];
    if (dotenvApiKey != null && dotenvApiKey.isNotEmpty && dotenvApiKey != 'your_resend_api_key_here') {
      return dotenvApiKey;
    }
    
    // Try to get from environment variable
    const envApiKey = String.fromEnvironment('RESEND_API_KEY');
    if (envApiKey.isNotEmpty && envApiKey != 'your_resend_api_key_here') {
      return envApiKey;
    }
    
    // Fallback to hardcoded value
    return 're_JQMZPEPm_BVgLvZS6AG2QzGt8UUTmTzgG';
  }
  
  /// Your verified domain email (must be verified in Resend dashboard)
  /// This will use environment variable if available, otherwise fallback to hardcoded value
  static String get resendFromEmail {
    // Try to get from .env file first
    final dotenvFromEmail = dotenv.env['RESEND_FROM_EMAIL'];
    if (dotenvFromEmail != null && dotenvFromEmail.isNotEmpty && dotenvFromEmail != 'your_resend_from_email_here') {
      return dotenvFromEmail;
    }
    
    // Try to get from environment variable
    const envFromEmail = String.fromEnvironment('RESEND_FROM_EMAIL');
    if (envFromEmail.isNotEmpty && envFromEmail != 'your_resend_from_email_here') {
      return envFromEmail;
    }
    
    // Fallback to hardcoded value
    return 'onboarding@resend.dev';
  }
  
  
  // ========================================
  // EMAIL TEMPLATE CONFIGURATION
  // ========================================
  static const String appName = 'SwiftRide';
  static const String supportEmail = 'support@swiftride.com';
  static const String companyName = 'SwiftRide';
  
  // ========================================
  // HELPER METHODS
  // ========================================
  
  /// Check if email service is configured
  static bool get isEmailConfigured {
    return emailService == 'resend' && 
           resendApiKey.isNotEmpty && 
           resendFromEmail.isNotEmpty;
  }
  
  /// Get configuration status message
  static String get configurationStatus {
    if (isEmailConfigured) {
      return '✅ Email service configured: $emailService';
    } else {
      return '⚠️ Email service not configured. Please update EmailConfig.dart';
    }
  }
  
  /// Get setup instructions for Resend
  static String get setupInstructions {
    return '''
📧 Resend Setup Instructions:
1. Go to https://resend.com and create an account
2. Verify your domain or use a test domain
3. Get your API key from https://resend.com/api-keys
4. Add RESEND_API_KEY to your .env file
5. Test the email functionality
    ''';
  }
}
