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
  static const String resendApiKey = 're_JQMZPEPm_BVgLvZS6AG2QzGt8UUTmTzgG';
  /// Your verified domain email (must be verified in Resend dashboard)
  static const String resendFromEmail = 'onboarding@resend.dev';
  
  // ========================================
  // SENDGRID CONFIGURATION
  // ========================================
  /// Get your API key from: https://app.sendgrid.com/settings/api_keys
  static const String sendgridApiKey = 'YOUR_SENDGRID_API_KEY';
  static const String sendgridFromEmail = 'noreply@yourdomain.com';
  
  // ========================================
  // MAILGUN CONFIGURATION
  // ========================================
  /// Get your API key from: https://app.mailgun.com/app/account/security/api_keys
  static const String mailgunApiKey = 'YOUR_MAILGUN_API_KEY';
  static const String mailgunDomain = 'yourdomain.mailgun.org';
  static const String mailgunFromEmail = 'noreply@yourdomain.com';
  
  // ========================================
  // EMAILJS CONFIGURATION
  // ========================================
  /// Get these from: https://www.emailjs.com/
  static const String emailJsServiceId = 'YOUR_EMAILJS_SERVICE_ID';
  static const String emailJsTemplateId = 'YOUR_EMAILJS_TEMPLATE_ID';
  static const String emailJsUserId = 'YOUR_EMAILJS_USER_ID';
  
  // ========================================
  // WEBHOOK CONFIGURATION
  // ========================================
  /// Your custom webhook endpoint URL
  static const String webhookUrl = 'YOUR_WEBHOOK_URL';
  
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
    switch (emailService) {
      case 'resend':
        return resendApiKey != 'YOUR_RESEND_API_KEY' && 
               resendFromEmail != 'noreply@yourdomain.com';
      case 'sendgrid':
        return sendgridApiKey != 'YOUR_SENDGRID_API_KEY' && 
               sendgridFromEmail != 'noreply@yourdomain.com';
      case 'mailgun':
        return mailgunApiKey != 'YOUR_MAILGUN_API_KEY' && 
               mailgunDomain != 'yourdomain.mailgun.org' &&
               mailgunFromEmail != 'noreply@yourdomain.com';
      case 'emailjs':
        return emailJsServiceId != 'YOUR_EMAILJS_SERVICE_ID' &&
               emailJsTemplateId != 'YOUR_EMAILJS_TEMPLATE_ID' &&
               emailJsUserId != 'YOUR_EMAILJS_USER_ID';
      case 'webhook':
        return webhookUrl != 'YOUR_WEBHOOK_URL';
      case 'none':
        return false;
      default:
        return false;
    }
  }
  
  /// Get configuration status message
  static String get configurationStatus {
    if (isEmailConfigured) {
      return '✅ Email service configured: $emailService';
    } else {
      return '⚠️ Email service not configured. Please update EmailConfig.dart';
    }
  }
  
  /// Get setup instructions for the current service
  static String get setupInstructions {
    switch (emailService) {
      case 'resend':
        return '''
📧 Resend Setup Instructions:
1. Go to https://resend.com and create an account
2. Verify your domain or use a test domain
3. Get your API key from https://resend.com/api-keys
4. Update resendApiKey and resendFromEmail in EmailConfig.dart
5. Test the email functionality
        ''';
      case 'sendgrid':
        return '''
📧 SendGrid Setup Instructions:
1. Go to https://app.sendgrid.com and create an account
2. Verify your sender identity
3. Create an API key at https://app.sendgrid.com/settings/api_keys
4. Update sendgridApiKey and sendgridFromEmail in EmailConfig.dart
5. Test the email functionality
        ''';
      case 'mailgun':
        return '''
📧 Mailgun Setup Instructions:
1. Go to https://app.mailgun.com and create an account
2. Add and verify your domain
3. Get your API key from https://app.mailgun.com/app/account/security/api_keys
4. Update mailgunApiKey, mailgunDomain, and mailgunFromEmail in EmailConfig.dart
5. Test the email functionality
        ''';
      case 'emailjs':
        return '''
📧 EmailJS Setup Instructions:
1. Go to https://www.emailjs.com/ and create an account
2. Create an email service (Gmail, Outlook, etc.)
3. Create an email template
4. Get your Service ID, Template ID, and User ID
5. Update emailJsServiceId, emailJsTemplateId, and emailJsUserId in EmailConfig.dart
6. Test the email functionality
        ''';
      case 'webhook':
        return '''
📧 Webhook Setup Instructions:
1. Create a webhook endpoint on your server
2. The endpoint should accept POST requests with booking data
3. Update webhookUrl in EmailConfig.dart
4. Your webhook should handle the email sending logic
5. Test the webhook functionality
        ''';
      case 'none':
        return '''
📧 No Email Service Configured:
Email notifications are disabled. To enable:
1. Choose an email service provider
2. Update emailService in EmailConfig.dart
3. Configure the required API keys and settings
4. Test the email functionality
        ''';
      default:
        return 'Invalid email service configuration.';
    }
  }
}
