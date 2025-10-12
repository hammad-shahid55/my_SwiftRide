import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swift_ride/Services/EmailConfig.dart';

class SimpleEmailService {
  // Using a simple approach with a webhook or email service
  // This can be easily configured with services like:
  // - Resend (resend.com)
  // - SendGrid
  // - Mailgun
  // - Or your own backend endpoint

  /// Send booking confirmation email using configured email service
  static Future<bool> sendBookingConfirmation({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) async {
    // Check if email service is configured
    if (!EmailConfig.isEmailConfigured) {
      print('⚠️ Email service not configured. Logging booking details instead.');
      _logBookingDetails(
        userEmail: userEmail,
        userName: userName,
        fromCity: fromCity,
        toCity: toCity,
        seats: seats,
        totalPrice: totalPrice,
        rideTime: rideTime,
        bookingId: bookingId,
      );
      return false;
    }

    try {
      switch (EmailConfig.emailService) {
        case 'resend':
          return await _sendWithResend(
            userEmail: userEmail,
            userName: userName,
            fromCity: fromCity,
            toCity: toCity,
            seats: seats,
            totalPrice: totalPrice,
            rideTime: rideTime,
            bookingId: bookingId,
          );
        case 'sendgrid':
          return await _sendWithSendGrid(
            userEmail: userEmail,
            userName: userName,
            fromCity: fromCity,
            toCity: toCity,
            seats: seats,
            totalPrice: totalPrice,
            rideTime: rideTime,
            bookingId: bookingId,
          );
        case 'mailgun':
          return await _sendWithMailgun(
            userEmail: userEmail,
            userName: userName,
            fromCity: fromCity,
            toCity: toCity,
            seats: seats,
            totalPrice: totalPrice,
            rideTime: rideTime,
            bookingId: bookingId,
          );
        case 'emailjs':
          return await _sendWithEmailJS(
            userEmail: userEmail,
            userName: userName,
            fromCity: fromCity,
            toCity: toCity,
            seats: seats,
            totalPrice: totalPrice,
            rideTime: rideTime,
            bookingId: bookingId,
          );
        case 'webhook':
          return await _sendWithWebhook(
            userEmail: userEmail,
            userName: userName,
            fromCity: fromCity,
            toCity: toCity,
            seats: seats,
            totalPrice: totalPrice,
            rideTime: rideTime,
            bookingId: bookingId,
          );
        default:
          print('❌ Unknown email service: ${EmailConfig.emailService}');
          _logBookingDetails(
            userEmail: userEmail,
            userName: userName,
            fromCity: fromCity,
            toCity: toCity,
            seats: seats,
            totalPrice: totalPrice,
            rideTime: rideTime,
            bookingId: bookingId,
          );
          return false;
      }
    } catch (e) {
      print('❌ Error in SimpleEmailService: $e');
      // Fallback: Just log the booking details
      _logBookingDetails(
        userEmail: userEmail,
        userName: userName,
        fromCity: fromCity,
        toCity: toCity,
        seats: seats,
        totalPrice: totalPrice,
        rideTime: rideTime,
        bookingId: bookingId,
      );
      return false;
    }
  }

  /// Send email using Resend API (free tier available)
  static Future<bool> _sendWithResend({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) async {
    try {
      final emailData = {
        'from': EmailConfig.resendFromEmail,
        'to': [userEmail],
        'subject': 'Booking Confirmation - ${EmailConfig.appName}',
        'html': _generateEmailHTML(
          userName: userName,
          fromCity: fromCity,
          toCity: toCity,
          seats: seats,
          totalPrice: totalPrice,
          rideTime: rideTime,
          bookingId: bookingId,
        ),
      };

      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EmailConfig.resendApiKey}',
        },
        body: json.encode(emailData),
      );

      if (response.statusCode == 200) {
        print('✅ Booking confirmation email sent to $userEmail via Resend');
        return true;
      } else {
        print('❌ Failed to send email via Resend: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email with Resend: $e');
      return false;
    }
  }

  /// Send email using SendGrid API
  static Future<bool> _sendWithSendGrid({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) async {
    try {
      final emailData = {
        'personalizations': [
          {
            'to': [{'email': userEmail}],
            'subject': 'Booking Confirmation - ${EmailConfig.appName}',
          }
        ],
        'from': {'email': EmailConfig.sendgridFromEmail},
        'content': [
          {
            'type': 'text/html',
            'value': _generateEmailHTML(
              userName: userName,
              fromCity: fromCity,
              toCity: toCity,
              seats: seats,
              totalPrice: totalPrice,
              rideTime: rideTime,
              bookingId: bookingId,
            ),
          }
        ],
      };

      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EmailConfig.sendgridApiKey}',
        },
        body: json.encode(emailData),
      );

      if (response.statusCode == 202) {
        print('✅ Booking confirmation email sent to $userEmail via SendGrid');
        return true;
      } else {
        print('❌ Failed to send email via SendGrid: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email with SendGrid: $e');
      return false;
    }
  }

  /// Send email using Mailgun API
  static Future<bool> _sendWithMailgun({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) async {
    try {
      final emailData = {
        'from': EmailConfig.mailgunFromEmail,
        'to': userEmail,
        'subject': 'Booking Confirmation - ${EmailConfig.appName}',
        'html': _generateEmailHTML(
          userName: userName,
          fromCity: fromCity,
          toCity: toCity,
          seats: seats,
          totalPrice: totalPrice,
          rideTime: rideTime,
          bookingId: bookingId,
        ),
      };

      final response = await http.post(
        Uri.parse('https://api.mailgun.net/v3/${EmailConfig.mailgunDomain}/messages'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('api:${EmailConfig.mailgunApiKey}'))}',
        },
        body: emailData,
      );

      if (response.statusCode == 200) {
        print('✅ Booking confirmation email sent to $userEmail via Mailgun');
        return true;
      } else {
        print('❌ Failed to send email via Mailgun: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email with Mailgun: $e');
      return false;
    }
  }

  /// Send email using EmailJS
  static Future<bool> _sendWithEmailJS({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) async {
    try {
      final emailData = {
        'service_id': EmailConfig.emailJsServiceId,
        'template_id': EmailConfig.emailJsTemplateId,
        'user_id': EmailConfig.emailJsUserId,
        'template_params': {
          'to_email': userEmail,
          'user_name': userName,
          'from_city': fromCity,
          'to_city': toCity,
          'seats': seats.toString(),
          'total_price': totalPrice.toString(),
          'ride_time': _formatRideTime(rideTime),
          'booking_id': bookingId,
          'booking_date': DateTime.now().toIso8601String().split('T')[0],
        }
      };

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(emailData),
      );

      if (response.statusCode == 200) {
        print('✅ Booking confirmation email sent to $userEmail via EmailJS');
        return true;
      } else {
        print('❌ Failed to send email via EmailJS: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email with EmailJS: $e');
      return false;
    }
  }

  /// Send email using webhook
  static Future<bool> _sendWithWebhook({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) async {
    try {
      final bookingData = {
        'type': 'booking_confirmation',
        'user_email': userEmail,
        'user_name': userName,
        'booking_details': {
          'booking_id': bookingId,
          'from_city': fromCity,
          'to_city': toCity,
          'seats': seats,
          'total_price': totalPrice,
          'ride_time': rideTime,
          'booking_date': DateTime.now().toIso8601String(),
        }
      };

      final response = await http.post(
        Uri.parse(EmailConfig.webhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(bookingData),
      );

      if (response.statusCode == 200) {
        print('✅ Booking confirmation webhook sent successfully');
        return true;
      } else {
        print('❌ Failed to send webhook: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending webhook: $e');
      return false;
    }
  }

  /// Generate HTML email content
  static String _generateEmailHTML({
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) {
    final formattedTime = _formatRideTime(rideTime);
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Booking Confirmation</title>
        <style>
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                line-height: 1.6; 
                color: #333; 
                margin: 0; 
                padding: 0; 
                background-color: #f4f4f4;
            }
            .container { 
                max-width: 600px; 
                margin: 20px auto; 
                background-color: white; 
                border-radius: 10px; 
                overflow: hidden;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            }
            .header { 
                background: linear-gradient(135deg, #FD5858, #ff6b6b); 
                color: white; 
                padding: 30px 20px; 
                text-align: center; 
            }
            .header h1 { margin: 0; font-size: 28px; }
            .header h2 { margin: 10px 0 0 0; font-size: 18px; opacity: 0.9; }
            .content { padding: 30px; }
            .greeting { font-size: 18px; margin-bottom: 20px; }
            .booking-card { 
                background-color: #f8f9fa; 
                border-radius: 8px; 
                padding: 20px; 
                margin: 20px 0; 
                border-left: 4px solid #FD5858;
            }
            .detail-row { 
                display: flex; 
                justify-content: space-between; 
                align-items: center;
                margin: 12px 0; 
                padding: 8px 0; 
                border-bottom: 1px solid #e9ecef; 
            }
            .detail-row:last-child { border-bottom: none; }
            .detail-label { 
                font-weight: 600; 
                color: #495057; 
                flex: 1;
            }
            .detail-value { 
                color: #212529; 
                font-weight: 500;
                text-align: right;
            }
            .total-price { 
                font-size: 20px; 
                font-weight: bold; 
                color: #FD5858; 
            }
            .booking-id { 
                background-color: #e3f2fd; 
                color: #1976d2; 
                padding: 4px 8px; 
                border-radius: 4px; 
                font-family: monospace;
            }
            .message { 
                background-color: #d4edda; 
                border: 1px solid #c3e6cb; 
                color: #155724; 
                padding: 15px; 
                border-radius: 5px; 
                margin: 20px 0;
            }
            .footer { 
                background-color: #f8f9fa; 
                padding: 20px; 
                text-align: center; 
                color: #6c757d; 
                font-size: 14px; 
                border-top: 1px solid #e9ecef;
            }
            .footer p { margin: 5px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚗 ${EmailConfig.appName}</h1>
                <h2>Booking Confirmed!</h2>
            </div>
            <div class="content">
                <div class="greeting">
                    Hello <strong>$userName</strong>! 👋
                </div>
                
                <p>Great news! Your ride has been successfully booked. Here are all the details:</p>
                
                <div class="booking-card">
                    <div class="detail-row">
                        <span class="detail-label">Booking ID:</span>
                        <span class="detail-value"><span class="booking-id">$bookingId</span></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">📍 From:</span>
                        <span class="detail-value">$fromCity</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">🎯 To:</span>
                        <span class="detail-value">$toCity</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">💺 Seats:</span>
                        <span class="detail-value">$seats</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">⏰ Ride Time:</span>
                        <span class="detail-value">$formattedTime</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">💰 Total Price:</span>
                        <span class="detail-value total-price">$totalPrice PKR</span>
                    </div>
                </div>
                
                <div class="message">
                    <strong>📱 What's Next?</strong><br>
                    • We'll send you a reminder before your ride<br>
                    • Keep this email for your records<br>
                    • Contact support if you need any changes
                </div>
                
                <p>Thank you for choosing ${EmailConfig.appName}! We're excited to get you to your destination safely and comfortably.</p>
            </div>
            <div class="footer">
                <p><strong>${EmailConfig.companyName}</strong> - Your reliable ride companion</p>
                <p>© 2024 ${EmailConfig.companyName}. All rights reserved.</p>
                <p><em>This is an automated message. Please do not reply to this email.</em></p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Format ride time for better display
  static String _formatRideTime(String rideTime) {
    try {
      final dateTime = DateTime.parse(rideTime);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      final day = dateTime.day;
      final month = months[dateTime.month - 1];
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      
      return '$day $month $year at $hour:$minute';
    } catch (e) {
      return rideTime;
    }
  }

  /// Fallback: Log booking details (for development/testing)
  static void _logBookingDetails({
    required String userEmail,
    required String userName,
    required String fromCity,
    required String toCity,
    required int seats,
    required int totalPrice,
    required String rideTime,
    required String bookingId,
  }) {
    print('📧 BOOKING CONFIRMATION EMAIL (Fallback Log)');
    print('==========================================');
    print('To: $userEmail');
    print('Name: $userName');
    print('From: $fromCity');
    print('To: $toCity');
    print('Seats: $seats');
    print('Total Price: $totalPrice PKR');
    print('Ride Time: ${_formatRideTime(rideTime)}');
    print('Booking ID: $bookingId');
    print('==========================================');
  }

  /// Test email functionality
  static Future<bool> testEmailService() async {
    return await sendBookingConfirmation(
      userEmail: 'test@example.com',
      userName: 'Test User',
      fromCity: 'Karachi',
      toCity: 'Lahore',
      seats: 2,
      totalPrice: 5000,
      rideTime: DateTime.now().add(Duration(days: 1)).toIso8601String(),
      bookingId: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
